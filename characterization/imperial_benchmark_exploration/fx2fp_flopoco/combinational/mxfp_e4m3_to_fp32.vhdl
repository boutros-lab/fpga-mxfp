--------------------------------------------------------------------------------
--                           IntAdder_43_comb_uid5
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2016)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X Y Cin
-- Output signals: R
--  approx. input signal timings: X: 0.000000nsY: 0.000000nsCin: 0.000000ns
--  approx. output signal timings: R: 1.420000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_43_comb_uid5 is
    port (X : in  std_logic_vector(42 downto 0);
          Y : in  std_logic_vector(42 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(42 downto 0)   );
end entity;

architecture arch of IntAdder_43_comb_uid5 is
signal Rtmp :  std_logic_vector(42 downto 0);
   -- timing of Rtmp: 1.420000ns
begin
   Rtmp <= X + Y + Cin;
   R <= Rtmp;
end architecture;

--------------------------------------------------------------------------------
--                     Normalizer_ZStk_43_25_43_comb_uid7
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X
-- Output signals: Count R Sticky
--  approx. input signal timings: X: 1.420000ns
--  approx. output signal timings: Count: 7.630000nsR: 8.180000nsSticky: 8.190000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_ZStk_43_25_43_comb_uid7 is
    port (X : in  std_logic_vector(42 downto 0);
          Count : out  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(24 downto 0);
          Sticky : out  std_logic   );
end entity;

architecture arch of Normalizer_ZStk_43_25_43_comb_uid7 is
signal level6 :  std_logic_vector(42 downto 0);
   -- timing of level6: 1.420000ns
signal sticky6 :  std_logic;
   -- timing of sticky6: 0.000000ns
signal count5 :  std_logic;
   -- timing of count5: 2.040000ns
signal level5 :  std_logic_vector(42 downto 0);
   -- timing of level5: 2.590000ns
signal sticky_high_5 :  std_logic;
   -- timing of sticky_high_5: 0.000000ns
signal sticky_low_5 :  std_logic;
   -- timing of sticky_low_5: 0.000000ns
signal sticky5 :  std_logic;
   -- timing of sticky5: 2.600000ns
signal count4 :  std_logic;
   -- timing of count4: 3.180000ns
signal level4 :  std_logic_vector(39 downto 0);
   -- timing of level4: 3.730000ns
signal sticky_high_4 :  std_logic;
   -- timing of sticky_high_4: 2.590000ns
signal sticky_low_4 :  std_logic;
   -- timing of sticky_low_4: 0.000000ns
signal sticky4 :  std_logic;
   -- timing of sticky4: 3.740000ns
signal count3 :  std_logic;
   -- timing of count3: 4.300000ns
signal level3 :  std_logic_vector(31 downto 0);
   -- timing of level3: 4.850000ns
signal sticky_high_3 :  std_logic;
   -- timing of sticky_high_3: 3.730000ns
signal sticky_low_3 :  std_logic;
   -- timing of sticky_low_3: 0.000000ns
signal sticky3 :  std_logic;
   -- timing of sticky3: 4.870000ns
signal count2 :  std_logic;
   -- timing of count2: 5.410000ns
signal level2 :  std_logic_vector(27 downto 0);
   -- timing of level2: 5.960000ns
signal sticky_high_2 :  std_logic;
   -- timing of sticky_high_2: 4.850000ns
signal sticky_low_2 :  std_logic;
   -- timing of sticky_low_2: 0.000000ns
signal sticky2 :  std_logic;
   -- timing of sticky2: 5.970000ns
signal count1 :  std_logic;
   -- timing of count1: 6.520000ns
signal level1 :  std_logic_vector(25 downto 0);
   -- timing of level1: 7.070000ns
signal sticky_high_1 :  std_logic;
   -- timing of sticky_high_1: 5.960000ns
signal sticky_low_1 :  std_logic;
   -- timing of sticky_low_1: 0.000000ns
signal sticky1 :  std_logic;
   -- timing of sticky1: 7.080000ns
signal count0 :  std_logic;
   -- timing of count0: 7.630000ns
signal level0 :  std_logic_vector(24 downto 0);
   -- timing of level0: 8.180000ns
signal sticky_high_0 :  std_logic;
   -- timing of sticky_high_0: 7.070000ns
signal sticky_low_0 :  std_logic;
   -- timing of sticky_low_0: 0.000000ns
signal sticky0 :  std_logic;
   -- timing of sticky0: 8.190000ns
signal sCount :  std_logic_vector(5 downto 0);
   -- timing of sCount: 7.630000ns
begin
   level6 <= X ;
   sticky6 <= '0' ;
   count5<= '1' when level6(42 downto 11) = (42 downto 11=>'0') else '0';
   level5<= level6(42 downto 0) when count5='0' else level6(10 downto 0) & (31 downto 0 => '0');
   sticky_high_5<= '0';
   sticky_low_5<= '0';
   sticky5<= sticky6 or sticky_high_5 when count5='0' else sticky6 or sticky_low_5;

   count4<= '1' when level5(42 downto 27) = (42 downto 27=>'0') else '0';
   level4<= level5(42 downto 3) when count4='0' else level5(26 downto 0) & (12 downto 0 => '0');
   sticky_high_4<= '0'when level5(2 downto 0) = CONV_STD_LOGIC_VECTOR(0,3) else '1';
   sticky_low_4<= '0';
   sticky4<= sticky5 or sticky_high_4 when count4='0' else sticky5 or sticky_low_4;

   count3<= '1' when level4(39 downto 32) = (39 downto 32=>'0') else '0';
   level3<= level4(39 downto 8) when count3='0' else level4(31 downto 0);
   sticky_high_3<= '0'when level4(7 downto 0) = CONV_STD_LOGIC_VECTOR(0,8) else '1';
   sticky_low_3<= '0';
   sticky3<= sticky4 or sticky_high_3 when count3='0' else sticky4 or sticky_low_3;

   count2<= '1' when level3(31 downto 28) = (31 downto 28=>'0') else '0';
   level2<= level3(31 downto 4) when count2='0' else level3(27 downto 0);
   sticky_high_2<= '0'when level3(3 downto 0) = CONV_STD_LOGIC_VECTOR(0,4) else '1';
   sticky_low_2<= '0';
   sticky2<= sticky3 or sticky_high_2 when count2='0' else sticky3 or sticky_low_2;

   count1<= '1' when level2(27 downto 26) = (27 downto 26=>'0') else '0';
   level1<= level2(27 downto 2) when count1='0' else level2(25 downto 0);
   sticky_high_1<= '0'when level2(1 downto 0) = CONV_STD_LOGIC_VECTOR(0,2) else '1';
   sticky_low_1<= '0';
   sticky1<= sticky2 or sticky_high_1 when count1='0' else sticky2 or sticky_low_1;

   count0<= '1' when level1(25 downto 25) = (25 downto 25=>'0') else '0';
   level0<= level1(25 downto 1) when count0='0' else level1(24 downto 0);
   sticky_high_0<= '0'when level1(0 downto 0) = CONV_STD_LOGIC_VECTOR(0,1) else '1';
   sticky_low_0<= '0';
   sticky0<= sticky1 or sticky_high_0 when count0='0' else sticky1 or sticky_low_0;

   R <= level0;
   sCount <= count5 & count4 & count3 & count2 & count1 & count0;
   Count <= sCount;
   Sticky <= sticky0;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_33_comb_uid10
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2016)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X Y Cin
-- Output signals: R
--  approx. input signal timings: X: 8.700000nsY: 9.290000nsCin: 0.000000ns
--  approx. output signal timings: R: 10.610000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_33_comb_uid10 is
    port (X : in  std_logic_vector(32 downto 0);
          Y : in  std_logic_vector(32 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(32 downto 0)   );
end entity;

architecture arch of IntAdder_33_comb_uid10 is
signal Rtmp :  std_logic_vector(32 downto 0);
   -- timing of Rtmp: 10.610000ns
begin
   Rtmp <= X + Y + Cin;
   R <= Rtmp;
end architecture;

--------------------------------------------------------------------------------
--                             MXFP_E4M3_to_FP32
--                    (Fix2FP_S_M18_24_to_8_23_comb_uid2)
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2026)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: I
-- Output signals: O
--  approx. input signal timings: I: 0.000000ns
--  approx. output signal timings: O: 11.160000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity MXFP_E4M3_to_FP32 is
    port (I : in  std_logic_vector(42 downto 0);
          O : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of MXFP_E4M3_to_FP32 is
   component IntAdder_43_comb_uid5 is
      port ( X : in  std_logic_vector(42 downto 0);
             Y : in  std_logic_vector(42 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(42 downto 0)   );
   end component;

   component Normalizer_ZStk_43_25_43_comb_uid7 is
      port ( X : in  std_logic_vector(42 downto 0);
             Count : out  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(24 downto 0);
             Sticky : out  std_logic   );
   end component;

   component IntAdder_33_comb_uid10 is
      port ( X : in  std_logic_vector(32 downto 0);
             Y : in  std_logic_vector(32 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(32 downto 0)   );
   end component;

signal sign :  std_logic;
   -- timing of sign: 0.000000ns
signal xoredI :  std_logic_vector(42 downto 0);
   -- timing of xoredI: 0.000000ns
signal bigSign :  std_logic_vector(42 downto 0);
   -- timing of bigSign: 0.000000ns
signal input :  std_logic_vector(42 downto 0);
   -- timing of input: 1.420000ns
signal overflow1 :  std_logic;
   -- timing of overflow1: 0.000000ns
signal sticky1 :  std_logic;
   -- timing of sticky1: 0.000000ns
signal input1 :  std_logic_vector(42 downto 0);
   -- timing of input1: 1.420000ns
signal lzc :  std_logic_vector(5 downto 0);
   -- timing of lzc: 7.630000ns
signal mantissa :  std_logic_vector(24 downto 0);
   -- timing of mantissa: 8.180000ns
signal sticky2 :  std_logic;
   -- timing of sticky2: 8.190000ns
signal sticky :  std_logic;
   -- timing of sticky: 8.740000ns
signal lzcP :  std_logic_vector(7 downto 0);
   -- timing of lzcP: 7.630000ns
signal zero :  std_logic;
   -- timing of zero: 8.180000ns
signal exponentCorrection :  std_logic_vector(7 downto 0);
   -- timing of exponentCorrection: 0.000000ns
signal exponentField :  std_logic_vector(7 downto 0);
   -- timing of exponentField: 8.700000ns
signal MSB2Signal :  std_logic_vector(7 downto 0);
   -- timing of MSB2Signal: 0.000000ns
signal expFrac :  std_logic_vector(31 downto 0);
   -- timing of expFrac: 8.700000ns
signal ulp :  std_logic;
   -- timing of ulp: 8.180000ns
signal roundbit :  std_logic;
   -- timing of roundbit: 8.180000ns
signal roundUp :  std_logic;
   -- timing of roundUp: 9.290000ns
signal roundAddend :  std_logic_vector(32 downto 0);
   -- timing of roundAddend: 9.290000ns
signal zExpFrac :  std_logic_vector(32 downto 0);
   -- timing of zExpFrac: 8.700000ns
signal roundedExpFrac :  std_logic_vector(32 downto 0);
   -- timing of roundedExpFrac: 10.610000ns
signal overflowInRound :  std_logic;
   -- timing of overflowInRound: 10.610000ns
signal finalOverflow :  std_logic;
   -- timing of finalOverflow: 10.610000ns
signal finalExpFrac :  std_logic_vector(30 downto 0);
   -- timing of finalExpFrac: 10.610000ns
signal exc :  std_logic_vector(1 downto 0);
   -- timing of exc: 11.160000ns
signal result :  std_logic_vector(33 downto 0);
   -- timing of result: 11.160000ns
begin
   sign <= I(42);
   xoredI <= I when sign='0' else not I;
   bigSign <= (42 downto 1 => '0') & sign;
   negateAdder: IntAdder_43_comb_uid5
      port map ( Cin => '0',
                 X => bigSign,
                 Y => xoredI,
                 R => input);
   overflow1 <= '0';
   sticky1 <= '0';
   input1 <= input(42 downto 0);
   normer: Normalizer_ZStk_43_25_43_comb_uid7
      port map ( X => input1,
                 Count => lzc,
                 R => mantissa,
                 Sticky => sticky2);
   sticky <= sticky1 or sticky2;
   lzcP <= "00"& lzc ;
   zero <= '1' when lzc >= CONV_STD_LOGIC_VECTOR(43,6)   else '0';
   exponentCorrection <= CONV_STD_LOGIC_VECTOR(151,8);
   exponentField <= exponentCorrection-lzcP;
   MSB2Signal<=CONV_STD_LOGIC_VECTOR(23,8);
   expFrac <= exponentField & (mantissa(23 downto 0)) ;
   ulp <=  mantissa(1);
   roundbit <=  mantissa(0);
   roundUp <=  '1' when roundbit='1' and (sticky='1' or (ulp='1' and sticky='0')) else '0';
   roundAddend <= "00000000000000000000000000000000" & roundUp;
   zExpFrac <= '0' & expFrac;
   roundingAdder: IntAdder_33_comb_uid10
      port map ( Cin => '0',
                 X => zExpFrac,
                 Y => roundAddend,
                 R => roundedExpFrac);
   overflowInRound <= roundedExpFrac(32);
   finalOverflow <= overflow1 or overflowInRound;
   finalExpFrac <=  roundedExpFrac(31 downto 1);
   exc <=  "10" when finalOverflow='1' else "00" when zero='1' else "01";
   result <=  exc & sign & finalExpFrac;
   O <= result;
end architecture;

