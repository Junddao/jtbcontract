class SoundSearcher
{
    static const int HANGUL_BEGIN_UNICODE = 44032;
    static const int HANGUL_LAST_UNICODE = 55203;
    static const int HANGUL_BASE_UNIT = 588;
    static final List<int> INITIAL_SOUND = ['ㄱ'.codeUnitAt(0), 'ㄲ'.codeUnitAt(0), 'ㄴ'.codeUnitAt(0), 'ㄷ'.codeUnitAt(0), 'ㄸ'.codeUnitAt(0), 'ㄹ'.codeUnitAt(0), 'ㅁ'.codeUnitAt(0), 'ㅂ'.codeUnitAt(0), 'ㅃ'.codeUnitAt(0), 'ㅅ'.codeUnitAt(0), 'ㅆ'.codeUnitAt(0), 'ㅇ'.codeUnitAt(0), 'ㅈ'.codeUnitAt(0), 'ㅉ'.codeUnitAt(0), 'ㅊ'.codeUnitAt(0), 'ㅋ'.codeUnitAt(0), 'ㅌ'.codeUnitAt(0), 'ㅍ'.codeUnitAt(0), 'ㅎ'.codeUnitAt(0)];

    static bool isInitialSound(int searchar)
    {
        for (int c in INITIAL_SOUND) {
            if (c == searchar) {
                return true;
            }
        }
        return false;
    }

    static int getInitialSound(int c)
    {
        int hanBegin = (c - HANGUL_BEGIN_UNICODE);
        int index = (hanBegin ~/ HANGUL_BASE_UNIT);
        return INITIAL_SOUND[index];
    }

    static bool isHangul(int c)
    {
        return (HANGUL_BEGIN_UNICODE <= c) && (c <= HANGUL_LAST_UNICODE);
    }

    SoundSearcher()
    {
    }

    static bool matchString(String value, String search)
    {
        int t = 0;
        int seof = (value.length - search.length);
        int slen = search.length;
        if (seof < 0) {
            return false;
        }
        for (int i = 0; i <= seof; i++) {
            t = 0;
            while (t < slen) {
                if ((isInitialSound(search.codeUnitAt(t)) == true) && isHangul(value.codeUnitAt(i + t))) {
                    if (getInitialSound(value.codeUnitAt(i + t)) == search.codeUnitAt(t)) {
                        t++;
                    } else {
                        break;
                    }
                } else {
                    if (value.codeUnitAt(i + t) == search.codeUnitAt(t)) {
                        t++;
                    } else {
                        break;
                    }
                }
            }
            if (t == slen) {
                return true;
            }
        }
        return false;
    }
}