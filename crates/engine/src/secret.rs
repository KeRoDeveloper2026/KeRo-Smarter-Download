//! Passwords and cookies on the disk: encrypted with the Windows user's own
//! key (DPAPI, `CryptProtectData`). Only the same Windows user on the same
//! computer can read them back; a settings or list file copied elsewhere (or
//! read by another user) shows no password.
//!
//! On the disk a protected text looks like `"dpapi:<hex>"`. Files of older
//! versions hold plain text: it is read as it is and protected on the next
//! save. Use the field attributes below:
//! Protection failures abort serialization; there is no plaintext fallback.
//!
//! ```ignore
//! #[serde(with = "crate::secret::string")]          pub password: String,
//! #[serde(default, with = "crate::secret::opt")]    pub cookies: Option<String>,
//! #[serde(default, with = "crate::secret::pair")]   pub auth: Option<(String, String)>,
//! ```

const PREFIX: &str = "dpapi:";

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ProtectionError;

impl std::fmt::Display for ProtectionError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("Secure storage is unavailable; sensitive data was not saved")
    }
}

impl std::error::Error for ProtectionError {}

#[cfg(test)]
std::thread_local! {
    static FAIL_PROTECTION: std::cell::Cell<bool> = const { std::cell::Cell::new(false) };
}

/// Fault injection is thread-local and absent from production builds.
#[cfg(test)]
pub(crate) fn with_failed_protection<T>(f: impl FnOnce() -> T) -> T {
    struct Reset(bool);
    impl Drop for Reset {
        fn drop(&mut self) {
            FAIL_PROTECTION.with(|v| v.set(self.0));
        }
    }
    let _reset = Reset(FAIL_PROTECTION.with(|v| v.replace(true)));
    f()
}

fn to_hex(b: &[u8]) -> String {
    b.iter().map(|x| format!("{x:02x}")).collect()
}

fn from_hex(s: &str) -> Option<Vec<u8>> {
    if !s.len().is_multiple_of(2) {
        return None;
    }
    (0..s.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(s.get(i..i + 2)?, 16).ok())
        .collect()
}

#[cfg(windows)]
mod os {
    use windows_sys::Win32::Foundation::LocalFree;
    use windows_sys::Win32::Security::Cryptography::{
        CryptProtectData, CryptUnprotectData, CRYPTPROTECT_UI_FORBIDDEN, CRYPT_INTEGER_BLOB,
    };

    fn run(data: &[u8], protect: bool) -> Option<Vec<u8>> {
        let input = CRYPT_INTEGER_BLOB {
            cbData: u32::try_from(data.len()).ok()?,
            pbData: data.as_ptr() as *mut u8,
        };
        let mut out = CRYPT_INTEGER_BLOB {
            cbData: 0,
            pbData: std::ptr::null_mut(),
        };
        // SAFETY: `input` points at `data`, which outlives the call and is only
        // read; on success Windows allocates `out` (LocalAlloc), which is
        // copied and then freed with LocalFree exactly once.
        unsafe {
            let ok = if protect {
                CryptProtectData(
                    &input,
                    std::ptr::null(),
                    std::ptr::null(),
                    std::ptr::null(),
                    std::ptr::null(),
                    CRYPTPROTECT_UI_FORBIDDEN,
                    &mut out,
                )
            } else {
                CryptUnprotectData(
                    &input,
                    std::ptr::null_mut(),
                    std::ptr::null(),
                    std::ptr::null(),
                    std::ptr::null(),
                    CRYPTPROTECT_UI_FORBIDDEN,
                    &mut out,
                )
            };
            if ok == 0 || out.pbData.is_null() {
                return None;
            }
            let bytes = std::slice::from_raw_parts(out.pbData, out.cbData as usize).to_vec();
            LocalFree(out.pbData as _);
            Some(bytes)
        }
    }

    pub fn protect(data: &[u8]) -> Option<Vec<u8>> {
        run(data, true)
    }
    pub fn unprotect(data: &[u8]) -> Option<Vec<u8>> {
        run(data, false)
    }
}

#[cfg(not(windows))]
mod os {
    // No secure backend on other systems: nonempty secrets cannot be saved.
    pub fn protect(_data: &[u8]) -> Option<Vec<u8>> {
        None
    }
    pub fn unprotect(_data: &[u8]) -> Option<Vec<u8>> {
        None
    }
}

/// Texts protected already in this run: the download list is saved every
/// few seconds and each protection is a Windows call, so the same cookie
/// text is protected once, not again and again. (Only in memory, where the
/// plain text is anyway.)
static SEALED: std::sync::Mutex<Option<std::collections::HashMap<String, String>>> =
    std::sync::Mutex::new(None);

/// The text as it is kept on the disk.
pub fn seal(plain: &str) -> Result<String, ProtectionError> {
    if plain.is_empty() {
        return Ok(String::new());
    }
    #[cfg(test)]
    if FAIL_PROTECTION.with(|v| v.get()) {
        return Err(ProtectionError);
    }
    let mut cache = SEALED.lock().unwrap_or_else(|p| p.into_inner());
    let map = cache.get_or_insert_with(Default::default);
    if let Some(done) = map.get(plain) {
        return Ok(done.clone());
    }
    let sealed = match os::protect(plain.as_bytes()) {
        Some(enc) if !enc.is_empty() => format!("{PREFIX}{}", to_hex(&enc)),
        _ => return Err(ProtectionError),
    };
    // a cookie text is a few KB: keep at most about a thousand of them
    if map.len() > 1000 {
        map.clear();
    }
    map.insert(plain.to_string(), sealed.clone());
    Ok(sealed)
}

/// The text from the disk. A protected text that can't be opened (another
/// user or computer) becomes empty: the user types the password again.
pub fn open(stored: &str) -> String {
    match stored.strip_prefix(PREFIX) {
        Some(hex) => from_hex(hex)
            .and_then(|b| os::unprotect(&b))
            .and_then(|b| String::from_utf8(b).ok())
            .unwrap_or_default(),
        None => stored.to_string(),
    }
}

pub mod string {
    use serde::{Deserialize, Deserializer, Serializer};
    pub fn serialize<S: Serializer>(v: &str, s: S) -> Result<S::Ok, S::Error> {
        let sealed = super::seal(v).map_err(<S::Error as serde::ser::Error>::custom)?;
        s.serialize_str(&sealed)
    }
    pub fn deserialize<'de, D: Deserializer<'de>>(d: D) -> Result<String, D::Error> {
        Ok(super::open(&String::deserialize(d)?))
    }
}

pub mod opt {
    use serde::{Deserialize, Deserializer, Serialize, Serializer};
    pub fn serialize<S: Serializer>(v: &Option<String>, s: S) -> Result<S::Ok, S::Error> {
        v.as_deref()
            .map(super::seal)
            .transpose()
            .map_err(<S::Error as serde::ser::Error>::custom)?
            .serialize(s)
    }
    pub fn deserialize<'de, D: Deserializer<'de>>(d: D) -> Result<Option<String>, D::Error> {
        Ok(Option::<String>::deserialize(d)?
            .map(|x| super::open(&x))
            .filter(|x| !x.is_empty()))
    }
}

pub mod pair {
    use serde::{Deserialize, Deserializer, Serialize, Serializer};
    pub fn serialize<S: Serializer>(v: &Option<(String, String)>, s: S) -> Result<S::Ok, S::Error> {
        let sealed = v
            .as_ref()
            .map(|(u, p)| super::seal(p).map(|password| (u.clone(), password)))
            .transpose()
            .map_err(<S::Error as serde::ser::Error>::custom)?;
        sealed.serialize(s)
    }
    pub fn deserialize<'de, D: Deserializer<'de>>(
        d: D,
    ) -> Result<Option<(String, String)>, D::Error> {
        Ok(Option::<(String, String)>::deserialize(d)?.map(|(u, p)| (u, super::open(&p))))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[derive(serde::Serialize, serde::Deserialize, PartialEq, Debug)]
    struct T {
        #[serde(with = "string")]
        p: String,
        #[serde(default, with = "opt")]
        c: Option<String>,
        #[serde(default, with = "pair")]
        a: Option<(String, String)>,
    }

    #[test]
    fn plain_text_of_old_files_still_reads() {
        let t: T = serde_json::from_str(r#"{"p":"pw","c":"k=v","a":["u","x"]}"#).unwrap();
        assert_eq!(
            t,
            T {
                p: "pw".into(),
                c: Some("k=v".into()),
                a: Some(("u".into(), "x".into()))
            }
        );
        #[cfg(windows)]
        {
            let json = serde_json::to_string(&t).unwrap();
            assert!(!json.contains("k=v"));
            assert!(json.contains(PREFIX));
            let back: T = serde_json::from_str(&json).unwrap();
            assert_eq!(back, t);
        }
        #[cfg(not(windows))]
        assert!(serde_json::to_string(&t).is_err());
    }

    #[test]
    fn unreadable_protected_text_is_empty_not_garbage() {
        assert_eq!(open("dpapi:zz"), "");
        assert_eq!(open("dpapi:00ff"), ""); // not this user's key
        let t: T = serde_json::from_str(r#"{"p":"dpapi:1234","c":"dpapi:","a":null}"#).unwrap();
        assert_eq!(t.p, "");
        assert_eq!(t.c, None);
        assert_eq!(seal(""), Ok(String::new()));
    }

    #[test]
    fn every_secret_serializer_refuses_plaintext_on_protection_failure() {
        for t in [
            T {
                p: "test-password".into(),
                c: None,
                a: None,
            },
            T {
                p: String::new(),
                c: Some("test-cookie=value".into()),
                a: None,
            },
            T {
                p: String::new(),
                c: None,
                a: Some(("user".into(), "test-auth-password".into())),
            },
        ] {
            with_failed_protection(|| {
                let error = serde_json::to_string(&t).unwrap_err().to_string();
                assert!(error.contains("Secure storage is unavailable"));
                assert!(!error.contains("test-password"));
                assert!(!error.contains("test-cookie"));
                assert!(!error.contains("test-auth-password"));
            });
        }
        with_failed_protection(|| {
            let t = T {
                p: String::new(),
                c: None,
                a: None,
            };
            assert!(serde_json::to_string(&t).is_ok());
        });
    }

    #[cfg(windows)]
    #[test]
    fn failed_protection_is_not_cached_and_legacy_data_migrates() {
        let plain = "test-cookie=retry-after-dpapi-failure";
        with_failed_protection(|| assert!(seal(plain).is_err()));
        let protected = seal(plain).unwrap();
        assert!(protected.starts_with(PREFIX));
        assert!(!protected.contains(plain));
        assert_eq!(open(&protected), plain);
        assert_eq!(seal(plain).unwrap(), protected);
    }
}
