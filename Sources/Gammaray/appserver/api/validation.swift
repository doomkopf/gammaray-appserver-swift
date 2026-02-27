func validate(str: String, minLength: Int, maxLength: Int) throws -> Bool {
    if str.count < minLength || str.count > maxLength {
        return false
    }
    return (try Regex("^[A-Za-z0-9-_]*$").wholeMatch(in: str)) != nil
}
