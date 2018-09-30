module hunt.string.StringUtils;

import std.ascii;
import std.conv;
import std.string;
import std.uni;

import hunt.container.ArrayTrie;
import hunt.container.Trie;
import hunt.string.common;


/**
*/
class StringUtils
{
    private enum string FOLDER_SEPARATOR = "/";
    private enum string WINDOWS_FOLDER_SEPARATOR = "\\";
    private enum string TOP_PATH = "..";
    private enum string CURRENT_PATH = ".";
    private enum char EXTENSION_SEPARATOR = '.';

    enum string EMPTY = "";
    enum string[] EMPTY_STRING_ARRAY = [];

    enum char[] lowercases = ['\000', '\001', '\002', '\003', '\004', '\005', '\006', '\007', '\010',
            '\011', '\012', '\013', '\014', '\015', '\016', '\017', '\020', '\021', '\022', '\023', '\024', '\025',
            '\026', '\027', '\030', '\031', '\032', '\033', '\034', '\035', '\036', '\037', '\040', '\041', '\042',
            '\043', '\044', '\045', '\046', '\047', '\050', '\051', '\052', '\053', '\054', '\055', '\056', '\057',
            '\060', '\061', '\062', '\063', '\064', '\065', '\066', '\067', '\070', '\071', '\072', '\073', '\074',
            '\075', '\076', '\077', '\100', '\141', '\142', '\143', '\144', '\145', '\146', '\147', '\150', '\151',
            '\152', '\153', '\154', '\155', '\156', '\157', '\160', '\161', '\162', '\163', '\164', '\165', '\166',
            '\167', '\170', '\171', '\172', '\133', '\134', '\135', '\136', '\137', '\140', '\141', '\142', '\143',
            '\144', '\145', '\146', '\147', '\150', '\151', '\152', '\153', '\154', '\155', '\156', '\157', '\160',
            '\161', '\162', '\163', '\164', '\165', '\166', '\167', '\170', '\171', '\172', '\173', '\174', '\175',
            '\176', '\177'];

    enum string __ISO_8859_1 = "iso-8859-1";
    enum string __UTF8 = "utf-8";
    enum string __UTF16 = "utf-16";
    
    // private enum string[string] CHARSETS = ["utf-8":__UTF8, "utf8":__UTF8, 
    //     "utf-16":__UTF16, "utf-8":__UTF16, 
    //     "iso-8859-1":__ISO_8859_1, "iso_8859_1":__ISO_8859_1];

    private __gshared Trie!string CHARSETS;

    shared static this() {
        CHARSETS = new ArrayTrie!string(256);

        CHARSETS.put("utf-8", __UTF8);
        CHARSETS.put("utf8", __UTF8);
        CHARSETS.put("utf-16", __UTF16);
        CHARSETS.put("utf16", __UTF16);
        CHARSETS.put("iso-8859-1", __ISO_8859_1);
        CHARSETS.put("iso_8859_1", __ISO_8859_1);
    }

    
    /**
     * Convert alternate charset names (eg utf8) to normalized name (eg UTF-8).
     *
     * @param s the charset to normalize
     * @return the normalized charset (or null if normalized version not found)
     */
    static string normalizeCharset(string s) {
        string n = CHARSETS.get(s);
        return (n is null) ? s : n;
    }

    /**
     * Convert alternate charset names (eg utf8) to normalized name (eg UTF-8).
     *
     * @param s      the charset to normalize
     * @param offset the offset in the charset
     * @param length the length of the charset in the input param
     * @return the normalized charset (or null if not found)
     */
    static string normalizeCharset(string s, int offset, int length) {
        return normalizeCharset(s[offset .. offset+length]);
    }

    static string asciiToLowerCase(string s)
    {
        return toLower(s);
    }

    static int toInt(string str, int from) {
        return to!int(str[from..$]);
    }

    static byte[] getBytes(string s) {
        return cast(byte[])s.dup;
    }

    // Splitting
    // -----------------------------------------------------------------------

    /**
     * <p>
     * Splits the provided text into an array, using whitespace as the
     * separator. Whitespace is defined by {@link Character#isWhitespace(char)}.
     * </p>
     * <p>
     * <p>
     * The separator is not included in the returned string array. Adjacent
     * separators are treated as one separator. For more control over the split
     * use the StrTokenizer class.
     * </p>
     * <p>
     * <p>
     * A <code>null</code> input string returns <code>null</code>.
     * </p>
     * <p>
     * <pre>
     * StringUtils.split(null)       = null
     * StringUtils.split("")         = []
     * StringUtils.split("abc def")  = ["abc", "def"]
     * StringUtils.split("abc  def") = ["abc", "def"]
     * StringUtils.split(" abc ")    = ["abc"]
     * </pre>
     *
     * @param str the string to parse, may be null
     * @return an array of parsed Strings, <code>null</code> if null string
     * input
     */
    static string[] split(string str) {
        return split(str, null, -1);
    }

    /**
     * <p>
     * Splits the provided text into an array, separators specified. This is an
     * alternative to using StringTokenizer.
     * </p>
     * <p>
     * <p>
     * The separator is not included in the returned string array. Adjacent
     * separators are treated as one separator. For more control over the split
     * use the StrTokenizer class.
     * </p>
     * <p>
     * <p>
     * A <code>null</code> input string returns <code>null</code>. A
     * <code>null</code> separatorChars splits on whitespace.
     * </p>
     * <p>
     * <pre>
     * StringUtils.split(null, *)         = null
     * StringUtils.split("", *)           = []
     * StringUtils.split("abc def", null) = ["abc", "def"]
     * StringUtils.split("abc def", " ")  = ["abc", "def"]
     * StringUtils.split("abc  def", " ") = ["abc", "def"]
     * StringUtils.split("ab:cd:ef", ":") = ["ab", "cd", "ef"]
     * </pre>
     *
     * @param str            the string to parse, may be null
     * @param separatorChars the characters used as the delimiters, <code>null</code>
     *                       splits on whitespace
     * @return an array of parsed Strings, <code>null</code> if null string
     * input
     */
    static string[] split(string str, string separatorChars) {
        return splitWorker(str, separatorChars, -1, false);
    }

    /**
     * <p>
     * Splits the provided text into an array, separator specified. This is an
     * alternative to using StringTokenizer.
     * </p>
     * <p>
     * <p>
     * The separator is not included in the returned string array. Adjacent
     * separators are treated as one separator. For more control over the split
     * use the StrTokenizer class.
     * </p>
     * <p>
     * <p>
     * A <code>null</code> input string returns <code>null</code>.
     * </p>
     * <p>
     * <pre>
     * StringUtils.split(null, *)         = null
     * StringUtils.split("", *)           = []
     * StringUtils.split("a.b.c", '.')    = ["a", "b", "c"]
     * StringUtils.split("a..b.c", '.')   = ["a", "b", "c"]
     * StringUtils.split("a:b:c", '.')    = ["a:b:c"]
     * StringUtils.split("a b c", ' ')    = ["a", "b", "c"]
     * </pre>
     *
     * @param str           the string to parse, may be null
     * @param separatorChar the character used as the delimiter
     * @return an array of parsed Strings, <code>null</code> if null string
     * input
     * @since 2.0
     */
    static string[] split(string str, char separatorChar) {
        return splitWorker(str, separatorChar, false);
    }

    /**
     * <p>
     * Splits the provided text into an array with a maximum length, separators
     * specified.
     * </p>
     * <p>
     * <p>
     * The separator is not included in the returned string array. Adjacent
     * separators are treated as one separator.
     * </p>
     * <p>
     * <p>
     * A <code>null</code> input string returns <code>null</code>. A
     * <code>null</code> separatorChars splits on whitespace.
     * </p>
     * <p>
     * <p>
     * If more than <code>max</code> delimited substrings are found, the last
     * returned string includes all characters after the first
     * <code>max - 1</code> returned strings (including separator characters).
     * </p>
     * <p>
     * <pre>
     * StringUtils.split(null, *, *)            = null
     * StringUtils.split("", *, *)              = []
     * StringUtils.split("ab de fg", null, 0)   = ["ab", "cd", "ef"]
     * StringUtils.split("ab   de fg", null, 0) = ["ab", "cd", "ef"]
     * StringUtils.split("ab:cd:ef", ":", 0)    = ["ab", "cd", "ef"]
     * StringUtils.split("ab:cd:ef", ":", 2)    = ["ab", "cd:ef"]
     * </pre>
     *
     * @param str            the string to parse, may be null
     * @param separatorChars the characters used as the delimiters, <code>null</code>
     *                       splits on whitespace
     * @param max            the maximum number of elements to include in the array. A zero
     *                       or negative value implies no limit
     * @return an array of parsed Strings, <code>null</code> if null string
     * input
     */
    static string[] split(string str, string separatorChars, int max) {
        return splitWorker(str, separatorChars, max, false);
    }

    /**
     * Performs the logic for the <code>split</code> and
     * <code>splitPreserveAllTokens</code> methods that return a maximum array
     * length.
     *
     * @param str               the string to parse, may be <code>null</code>
     * @param separatorChars    the separate character
     * @param max               the maximum number of elements to include in the array. A zero
     *                          or negative value implies no limit.
     * @param preserveAllTokens if <code>true</code>, adjacent separators are treated as empty
     *                          token separators; if <code>false</code>, adjacent separators
     *                          are treated as one separator.
     * @return an array of parsed Strings, <code>null</code> if null string
     * input
     */
    private static string[] splitWorker(string str, string separatorChars, int max, bool preserveAllTokens) {
        // Performance tuned for 2.0 (JDK1.4)
        // Direct code is quicker than StringTokenizer.
        // Also, StringTokenizer uses isSpace() not isWhitespace()

        if (str is null) {
            return null;
        }
        int len = cast(int)str.length;
        if (len == 0) {
            return EMPTY_STRING_ARRAY;
        }

        string[] list; // = new ArrayList!(string)();
        int sizePlus1 = 1;
        int i = 0, start = 0;
        bool match = false;
        bool lastMatch = false;
        if (separatorChars is null) {
            // Null separator means use whitespace
            while (i < len) {                
                if (std.ascii.isWhite(str[i])) {
                    if (match || preserveAllTokens) {
                        lastMatch = true;
                        if (sizePlus1++ == max) {
                            i = len;
                            lastMatch = false;
                        }
                        list ~= (str.substring(start, i));
                        match = false;
                    }
                    start = ++i;
                    continue;
                }
                lastMatch = false;
                match = true;
                i++;
            }
        } else if (separatorChars.length == 1) {
            // Optimise 1 character case
            char sep = separatorChars[0];
            while (i < len) {
                if (str[i] == sep) {
                    if (match || preserveAllTokens) {
                        lastMatch = true;
                        if (sizePlus1++ == max) {
                            i = len;
                            lastMatch = false;
                        }
                        list  ~= (str.substring(start, i));
                        match = false;
                    }
                    start = ++i;
                    continue;
                }
                lastMatch = false;
                match = true;
                i++;
            }
        } else {
            // standard case
            while (i < len) {
                if (separatorChars.indexOf(str[i]) >= 0) {
                    if (match || preserveAllTokens) {
                        lastMatch = true;
                        if (sizePlus1++ == max) {
                            i = len;
                            lastMatch = false;
                        }
                        list ~= (str.substring(start, i));
                        match = false;
                    }
                    start = ++i;
                    continue;
                }
                lastMatch = false;
                match = true;
                i++;
            }
        }
        if (match || (preserveAllTokens && lastMatch)) {
            list ~= (str.substring(start, i));
        }
        return list; //.toArray(EMPTY_STRING_ARRAY);
    }

    /**
     * Performs the logic for the <code>split</code> and
     * <code>splitPreserveAllTokens</code> methods that do not return a maximum
     * array length.
     *
     * @param str               the string to parse, may be <code>null</code>
     * @param separatorChar     the separate character
     * @param preserveAllTokens if <code>true</code>, adjacent separators are treated as empty
     *                          token separators; if <code>false</code>, adjacent separators
     *                          are treated as one separator.
     * @return an array of parsed Strings, <code>null</code> if null string
     * input
     */
    private static string[] splitWorker(string str, char separatorChar, bool preserveAllTokens) {
        // Performance tuned for 2.0 (JDK1.4)

        if (str is null) {
            return null;
        }
        int len = cast(int)str.length;
        if (len == 0) {
            return EMPTY_STRING_ARRAY;
        }
        string[] list; // = new ArrayList!(string)();
        int i = 0, start = 0;
        bool match = false;
        bool lastMatch = false;
        while (i < len) {
            if (str[i] == separatorChar) {
                if (match || preserveAllTokens) {
                    list ~= (str.substring(start, i));
                    match = false;
                    lastMatch = true;
                }
                start = ++i;
                continue;
            }
            lastMatch = false;
            match = true;
            i++;
        }
        if (match || (preserveAllTokens && lastMatch)) {
            list ~= (str.substring(start, i));
        }
        return list;
    }
}