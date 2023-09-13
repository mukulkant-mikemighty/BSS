function r = s_to_r ( s )
%% S_TO_R reads a real number from a string.
%
%
%  Discussion:
%
%    This routine will read as many characters as possible until it reaches
%    the end of the string, or encounters a character which cannot be
%    part of the real number.
%
%    Legal input is:
%
%       1 blanks,
%       2 '+' or '-' sign,
%       2.5 spaces
%       3 integer part,
%       4 decimal point,
%       5 fraction part,
%       6 'E' or 'e' or 'D' or 'd', exponent marker,
%       7 exponent sign,
%       8 exponent integer part,
%       9 exponent decimal point,
%      10 exponent fraction part,
%      11 blanks,
%      12 final comma or semicolon.
%
%    with most quantities optional.
%
%  Examples:
%
%    S                 R
%
%    '1'               1.0
%    '     1   '       1.0
%    '1A'              1.0
%    '12,34,56'        12.0
%    '  34 7'          34.0
%    '-1E2ABCD'        -100.0
%    '-1X2ABCD'        -1.0
%    ' 2E-1'           0.2
%    '23.45'           23.45
%    '-4.2E+2'         -420.0
%    '17d2'            1700.0
%    '-14e-2'         -0.14
%    'e2'              100.0
%    '-12.73e-9.23'   -12.73 * 10.0**(-9.23)
%
%  Modified:
%
%    22 November 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character ( len = * ) S, the string containing the
%    data to be read.  Reading will begin at position 1 and
%    terminate at the end of the string, or when no more
%    characters can be read to form a legal real.  Blanks,
%    commas, or other nonnumeric data will, in particular,
%    cause the conversion to halt.
%
%    Output, real R, the real value that was read from the string.
%
  s_length = s_len_trim ( s );
  ierror = 0;
  r = 0.0E+00;
  r_length = -1;
  isgn = 1;
  rtop = 0.0E+00;
  rbot = 1.0E+00;
  jsgn = 1;
  jtop = 0;
  jbot = 1;
  ihave = 1;
  iterm = 0;

  while ( 1 )

    r_length = r_length + 1;
    c = s(r_length+1);
%
%  Blank character.
%
    if ( c == ' ' )

      if ( ihave == 2 )

      elseif ( ihave == 6 | ihave == 7 )
        iterm = 1;
      elseif ( 1 < ihave )
        ihave = 11;
      end
%
%  Comma.
%
    elseif ( c == ',' | c == ';' )

      if ( ihave ~= 1 )
        iterm = 1;
        ihave = 12;
        r_length = r_length + 1;
      end
%
%  Minus sign.
%
    elseif ( c == '-' )

      if ( ihave == 1 );
        ihave = 2;
        isgn = -1;
      elseif ( ihave == 6 )
        ihave = 7;
        jsgn = -1;
      else
        iterm = 1;
      end
%
%  Plus sign.
%
    elseif ( c == '+' )

      if ( ihave == 1 )
        ihave = 2;
      elseif ( ihave == 6 )
        ihave = 7;
      else
        iterm = 1;
      end
%
%  Decimal point.
%
    elseif ( c == '.' )

      if ( ihave < 4 )
        ihave = 4;
      elseif ( 6 <= ihave & ihave <= 8 )
        ihave = 9;
      else
        iterm = 1;
      end
%
%  Exponent marker.
%
    elseif ( ch_eqi ( c, 'E' ) | ch_eqi ( c, 'D' ) )

      if ( ihave < 6 )
        ihave = 6;
      else
        iterm = 1;
      end
%
%  Digit.
%
    elseif ( ihave < 11 & ch_is_digit ( c ) )

      if ( ihave <= 2 )
        ihave = 3;
      elseif ( ihave == 4 )
        ihave = 5;
      elseif ( ihave == 6 | ihave == 7 )
        ihave = 8;
      elseif ( ihave == 9 )
        ihave = 10;
      end

      d = ch_to_digit ( c );

      if ( ihave == 3 )
        rtop = 10.0E+00 * rtop + d;
      elseif ( ihave == 5 )
        rtop = 10.0E+00 * rtop + d;
        rbot = 10.0E+00 * rbot;
      elseif ( ihave == 8 )
        jtop = 10 * jtop + d;
      elseif ( ihave == 10 )
        jtop = 10 * jtop + d;
        jbot = 10 * jbot;
      end
%
%  Anything else is regarded as a terminator.
%
    else
      iterm = 1;
    end
%
%  If we haven't seen a terminator, and we haven't examined the
%  entire string, go get the next character.
%
    if ( iterm == 1 | s_length <= r_length + 1 )
      break;
    end

  end
%
%  If we haven't seen a terminator, and we have examined the
%  entire string, then we're done, and R_LENGTH is equal to S_LENGTH.
%
  if ( iterm ~= 1 & r_length + 1 == s_length )
    r_length = s_length;
  end
%
%  Number seems to have terminated.  Have we got a legal number?
%  Not if we terminated in states 1, 2, 6 or 7!
%
  if ( ihave == 1 | ihave == 2 | ihave == 6 | ihave == 7 )
    ierror = ihave;
    fprintf ( 1, '\n' );
    fprintf ( 1, 'S_TO_R - Fatal error!\n' );
    fprintf ( 1, '  IHAVE = %d\n', ihave );
    error ( 'S_TO_R - Fatal error!' );
  end
%
%  Number seems OK.  Form it.
%
  if ( jtop == 0 )
    rexp = 1.0E+00;
  else

    if ( jbot == 1 )
      rexp = 10.0E+00.^( jsgn * jtop );
    else
      rexp = jsgn * jtop;
      rexp = rexp / jbot;
      rexp = 10.0E+00.^rexp;
    end

  end

  r = isgn * rexp * rtop / rbot;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function len = s_len_trim ( s )

% S_LEN_TRIM returns the length of a character string to the last nonblank.
%
%  Modified:
%
%    14 June 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S, the string to be measured.
%
%    Output, integer LENGTH, the length of the string up to the last nonblank.
%
  len = length ( s );

  while ( 0 < len )
    if ( s(len) ~= ' ' )
      return
    end
    len = len - 1;
  end
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function truefalse = ch_eqi ( c1, c2 )

%% CH_EQI is a case insensitive comparison of two characters for equality.
%
%  Examples:
%
%    CH_EQI ( 'A', 'a' ) is TRUE.
%
%  Modified:
%
%    28 July 2000
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C1, C2, the characters to compare.
%
%    Output, logical TRUEFALSE, is TRUE (1) if the characters are equal.
%
  FALSE = 0;
  TRUE = 1;

  if ( ch_cap ( c1 ) == ch_cap ( c2 ) )
    truefalse = TRUE;
  else
    truefalse = FALSE;
  end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function c2 = ch_cap ( c )

%% CH_CAP capitalizes a single character.
%
%  Modified:
%
%    22 November 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C, the character to capitalize.
%
%    Output, character C2, the capitalized character.
%
  if ( 'a' <= c & c <= 'z' )
    c2 = c + 'A' - 'a';
  else
    c2 = c;
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function truefalse = ch_is_digit ( c )

% CH_IS_DIGIT returns TRUE if the character C is a digit.
%
%  Modified:
%
%    11 December 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C, a character.
%
%    Output, integer TRUEFALSE, is TRUE (1) if C is a digit, FALSE (0) otherwise.
%
  TRUE = 1;
  FALSE = 0;

  if ( '0' <= c & c <= '9' )
    truefalse = TRUE;
  else
    truefalse = FALSE;
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function digit = ch_to_digit ( c )

%% CH_TO_DIGIT returns the integer value of a base 10 digit.
%
%  Example:
%
%     C   DIGIT
%    ---  -----
%    '0'    0
%    '1'    1
%    ...  ...
%    '9'    9
%    ' '    0
%    'X'   -1
%
%  Modified:
%
%    22 November 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C, the decimal digit, '0' through '9' or blank
%    are legal.
%
%    Output, integer DIGIT, the corresponding integer value.  If C was
%    'illegal', then DIGIT is -1.
%
  if ( '0' <= c & c <= '9' )

    digit = c - '0';

  elseif ( c == ' ' )

    digit = 0;

  else

    digit = -1;

  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  
  