# The URI::REGEXP module is being replaced, because the original
# implementation raises a URI::InvalidURIError for URIs that have square
# brackets in the path (i.e. http://example.com/file[1].pdf).
# 
# The only real change is to the REGEXP::PATTERN::UNRESERVED and
# REGEXP::PATTERN::RESERVED, but a lot of other stuff builds on these, so
# the whole thing needs to be replaced. This is, of course, why constants
# are evil.

require 'uri'
require 'uri/common'
module URI
  remove_const( 'REGEXP' )
  module REGEXP
    #
    # Patterns used to parse URI's
    #
    module PATTERN
      # :stopdoc:

      # RFC 2396 (URI Generic Syntax)
      # RFC 2732 (IPv6 Literal Addresses in URL's)
      # RFC 2373 (IPv6 Addressing Architecture)

      # alpha         = lowalpha | upalpha
      ALPHA = "a-zA-Z"
      # alphanum      = alpha | digit
      ALNUM = "#{ALPHA}\\d"

      # hex           = digit | "A" | "B" | "C" | "D" | "E" | "F" |
      #                         "a" | "b" | "c" | "d" | "e" | "f"
      HEX     = "a-fA-F\\d"
      # escaped       = "%" hex hex
      ESCAPED = "%[#{HEX}]{2}"
      # mark          = "-" | "_" | "." | "!" | "~" | "*" | "'" |
      #                 "(" | ")" | "[" | "]" 
      # unreserved    = alphanum | mark
      UNRESERVED = "-_.!~*'()#{ALNUM}\\[\\]"
      # reserved      = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" |
      #                 "$" | ","
      # reserved      = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" | 
      #                 "$" | "," (RFC 2732)
      RESERVED = ";/?:@&=+$,"

      # uric          = reserved | unreserved | escaped
      URIC = "(?:[#{UNRESERVED}#{RESERVED}]|#{ESCAPED})"
      # uric_no_slash = unreserved | escaped | ";" | "?" | ":" | "@" |
      #                 "&" | "=" | "+" | "$" | ","
      URIC_NO_SLASH = "(?:[#{UNRESERVED};?:@&=+$,]|#{ESCAPED})"
      # query         = *uric
      QUERY = "#{URIC}*"
      # fragment      = *uric
      FRAGMENT = "#{URIC}*"

      # domainlabel   = alphanum | alphanum *( alphanum | "-" ) alphanum
      DOMLABEL = "(?:[#{ALNUM}](?:[-#{ALNUM}]*[#{ALNUM}])?)"
      # toplabel      = alpha | alpha *( alphanum | "-" ) alphanum
      TOPLABEL = "(?:[#{ALPHA}](?:[-#{ALNUM}]*[#{ALNUM}])?)"
      # hostname      = *( domainlabel "." ) toplabel [ "." ]
      HOSTNAME = "(?:#{DOMLABEL}\\.)*#{TOPLABEL}\\.?"

      # RFC 2373, APPENDIX B:
      # IPv6address = hexpart [ ":" IPv4address ]
      # IPv4address   = 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT
      # hexpart = hexseq | hexseq "::" [ hexseq ] | "::" [ hexseq ]
      # hexseq  = hex4 *( ":" hex4)
      # hex4    = 1*4HEXDIG
      #
      # XXX: This definition has a flaw. "::" + IPv4address must be
      # allowed too.  Here is a replacement.
      #
      # IPv4address = 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT "." 1*3DIGIT
      IPV4ADDR = "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}"
      # hex4     = 1*4HEXDIG
      HEX4 = "[#{HEX}]{1,4}"
      # lastpart = hex4 | IPv4address
      LASTPART = "(?:#{HEX4}|#{IPV4ADDR})"
      # hexseq1  = *( hex4 ":" ) hex4
      HEXSEQ1 = "(?:#{HEX4}:)*#{HEX4}"
      # hexseq2  = *( hex4 ":" ) lastpart
      HEXSEQ2 = "(?:#{HEX4}:)*#{LASTPART}"
      # IPv6address = hexseq2 | [ hexseq1 ] "::" [ hexseq2 ]
      IPV6ADDR = "(?:#{HEXSEQ2}|(?:#{HEXSEQ1})?::(?:#{HEXSEQ2})?)"

      # IPv6prefix  = ( hexseq1 | [ hexseq1 ] "::" [ hexseq1 ] ) "/" 1*2DIGIT
      # unused

      # ipv6reference = "[" IPv6address "]" (RFC 2732)
      IPV6REF = "\\[#{IPV6ADDR}\\]"

      # host          = hostname | IPv4address
      # host          = hostname | IPv4address | IPv6reference (RFC 2732)
      HOST = "(?:#{HOSTNAME}|#{IPV4ADDR}|#{IPV6REF})"
      # port          = *digit
      PORT = '\d*'
      # hostport      = host [ ":" port ]
      HOSTPORT = "#{HOST}(?::#{PORT})?"

      # userinfo      = *( unreserved | escaped |
      #                    ";" | ":" | "&" | "=" | "+" | "$" | "," )
      USERINFO = "(?:[#{UNRESERVED};:&=+$,]|#{ESCAPED})*"

      # pchar         = unreserved | escaped |
      #                 ":" | "@" | "&" | "=" | "+" | "$" | ","
      PCHAR = "(?:[#{UNRESERVED}:@&=+$,]|#{ESCAPED})"
      # param         = *pchar
      PARAM = "#{PCHAR}*"
      # segment       = *pchar *( ";" param )
      SEGMENT = "#{PCHAR}*(?:;#{PARAM})*"
      # path_segments = segment *( "/" segment )
      PATH_SEGMENTS = "#{SEGMENT}(?:/#{SEGMENT})*"

      # server        = [ [ userinfo "@" ] hostport ]
      SERVER = "(?:#{USERINFO}@)?#{HOSTPORT}"
      # reg_name      = 1*( unreserved | escaped | "$" | "," |
      #                     ";" | ":" | "@" | "&" | "=" | "+" )
      REG_NAME = "(?:[#{UNRESERVED}$,;+@&=+]|#{ESCAPED})+"
      # authority     = server | reg_name
      AUTHORITY = "(?:#{SERVER}|#{REG_NAME})"

      # rel_segment   = 1*( unreserved | escaped |
      #                     ";" | "@" | "&" | "=" | "+" | "$" | "," )
      REL_SEGMENT = "(?:[#{UNRESERVED};@&=+$,]|#{ESCAPED})+"

      # scheme        = alpha *( alpha | digit | "+" | "-" | "." )
      SCHEME = "[#{ALPHA}][-+.#{ALPHA}\\d]*"

      # abs_path      = "/"  path_segments
      ABS_PATH = "/#{PATH_SEGMENTS}"
      # rel_path      = rel_segment [ abs_path ]
      REL_PATH = "#{REL_SEGMENT}(?:#{ABS_PATH})?"
      # net_path      = "//" authority [ abs_path ]
      NET_PATH   = "//#{AUTHORITY}(?:#{ABS_PATH})?"

      # hier_part     = ( net_path | abs_path ) [ "?" query ]
      HIER_PART   = "(?:#{NET_PATH}|#{ABS_PATH})(?:\\?(?:#{QUERY}))?"
      # opaque_part   = uric_no_slash *uric
      OPAQUE_PART = "#{URIC_NO_SLASH}#{URIC}*"

      # absoluteURI   = scheme ":" ( hier_part | opaque_part )
      ABS_URI   = "#{SCHEME}:(?:#{HIER_PART}|#{OPAQUE_PART})"
      # relativeURI   = ( net_path | abs_path | rel_path ) [ "?" query ]
      REL_URI = "(?:#{NET_PATH}|#{ABS_PATH}|#{REL_PATH})(?:\\?#{QUERY})?"

      # URI-reference = [ absoluteURI | relativeURI ] [ "#" fragment ]
      URI_REF = "(?:#{ABS_URI}|#{REL_URI})?(?:##{FRAGMENT})?"

      # XXX:
      X_ABS_URI = "
        (#{PATTERN::SCHEME}):                     (?# 1: scheme)
        (?:
           (#{PATTERN::OPAQUE_PART})              (?# 2: opaque)
        |
           (?:(?:
             //(?:
                 (?:(?:(#{PATTERN::USERINFO})@)?  (?# 3: userinfo)
                   (?:(#{PATTERN::HOST})(?::(\\d*))?))?(?# 4: host, 5: port)
               |
                 (#{PATTERN::REG_NAME})           (?# 6: registry)
               )
             |
             (?!//))                              (?# XXX: '//' is the mark for hostport)
             (#{PATTERN::ABS_PATH})?              (?# 7: path)
           )(?:\\?(#{PATTERN::QUERY}))?           (?# 8: query)
        )
        (?:\\#(#{PATTERN::FRAGMENT}))?            (?# 9: fragment)
      "
      X_REL_URI = "
        (?:
          (?:
            //
            (?:
              (?:(#{PATTERN::USERINFO})@)?       (?# 1: userinfo)
                (#{PATTERN::HOST})?(?::(\\d*))?  (?# 2: host, 3: port)
            |
              (#{PATTERN::REG_NAME})             (?# 4: registry)
            )
          )
        |
          (#{PATTERN::REL_SEGMENT})              (?# 5: rel_segment)
        )?
        (#{PATTERN::ABS_PATH})?                  (?# 6: abs_path)
        (?:\\?(#{PATTERN::QUERY}))?              (?# 7: query)
        (?:\\#(#{PATTERN::FRAGMENT}))?           (?# 8: fragment)
      "
      # :startdoc:
    end # PATTERN

    # :stopdoc:

    # for URI::split
    ABS_URI = Regexp.new('^' + PATTERN::X_ABS_URI + '$', #'
                         Regexp::EXTENDED, 'N').freeze
    REL_URI = Regexp.new('^' + PATTERN::X_REL_URI + '$', #'
                         Regexp::EXTENDED, 'N').freeze

    # for URI::extract
    URI_REF     = Regexp.new(PATTERN::URI_REF, false, 'N').freeze
    ABS_URI_REF = Regexp.new(PATTERN::X_ABS_URI, Regexp::EXTENDED, 'N').freeze
    REL_URI_REF = Regexp.new(PATTERN::X_REL_URI, Regexp::EXTENDED, 'N').freeze

    # for URI::escape/unescape
    ESCAPED = Regexp.new(PATTERN::ESCAPED, false, 'N').freeze
    UNSAFE  = Regexp.new("[^#{PATTERN::UNRESERVED}#{PATTERN::RESERVED}]",
                         false, 'N').freeze

    # for Generic#initialize
    SCHEME   = Regexp.new("^#{PATTERN::SCHEME}$", false, 'N').freeze #"
    USERINFO = Regexp.new("^#{PATTERN::USERINFO}$", false, 'N').freeze #"
    HOST     = Regexp.new("^#{PATTERN::HOST}$", false, 'N').freeze #"
    PORT     = Regexp.new("^#{PATTERN::PORT}$", false, 'N').freeze #"
    OPAQUE   = Regexp.new("^#{PATTERN::OPAQUE_PART}$", false, 'N').freeze #"
    REGISTRY = Regexp.new("^#{PATTERN::REG_NAME}$", false, 'N').freeze #"
    ABS_PATH = Regexp.new("^#{PATTERN::ABS_PATH}$", false, 'N').freeze #"
    REL_PATH = Regexp.new("^#{PATTERN::REL_PATH}$", false, 'N').freeze #"
    QUERY    = Regexp.new("^#{PATTERN::QUERY}$", false, 'N').freeze #"
    FRAGMENT = Regexp.new("^#{PATTERN::FRAGMENT}$", false, 'N').freeze #"
    # :startdoc:
  end # REGEXP
end