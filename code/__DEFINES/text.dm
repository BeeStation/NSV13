#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))
