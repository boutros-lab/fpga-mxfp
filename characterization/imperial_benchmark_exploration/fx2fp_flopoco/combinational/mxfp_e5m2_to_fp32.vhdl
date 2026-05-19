--------------------------------------------------------------------------------
--                           IntAdder_73_comb_uid5
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
--  approx. output signal timings: R: 1.720000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_73_comb_uid5 is
    port (X : in  std_logic_vector(72 downto 0);
          Y : in  std_logic_vector(72 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of IntAdder_73_comb_uid5 is
signal Rtmp :  std_logic_vector(72 downto 0);
   -- timing of Rtmp: 1.720000ns
begin
   Rtmp <= X + Y + Cin;
   R <= Rtmp;
end architecture;

--------------------------------------------------------------------------------
--                     Normalizer_ZStk_73_25_73_comb_uid7
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
--  approx. input signal timings: X: 1.720000ns
--  approx. output signal timings: Count: 9.160000nsR: 9.710000nsSticky: 9.720000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_ZStk_73_25_73_comb_uid7 is
    port (X : in  std_logic_vector(72 downto 0);
          Count : out  std_logic_vector(6 downto 0);
          R : out  std_logic_vector(24 downto 0);
          Sticky : out  std_logic   );
end entity;

architecture arch of Normalizer_ZStk_73_25_73_comb_uid7 is
signal level7 :  std_logic_vector(72 downto 0);
   -- timing of level7: 1.720000ns
signal sticky7 :  std_logic;
   -- timing of sticky7: 0.000000ns
signal count6 :  std_logic;
   -- timing of count6: 2.400000ns
signal level6 :  std_logic_vector(72 downto 0);
   -- timing of level6: 2.950000ns
signal sticky_high_6 :  std_logic;
   -- timing of sticky_high_6: 0.000000ns
signal sticky_low_6 :  std_logic;
   -- timing of sticky_low_6: 0.000000ns
signal sticky6 :  std_logic;
   -- timing of sticky6: 2.960000ns
signal count5 :  std_logic;
   -- timing of count5: 3.570000ns
signal level5 :  std_logic_vector(62 downto 0);
   -- timing of level5: 4.120000ns
signal sticky_high_5 :  std_logic;
   -- timing of sticky_high_5: 2.950000ns
signal sticky_low_5 :  std_logic;
   -- timing of sticky_low_5: 0.000000ns
signal sticky5 :  std_logic;
   -- timing of sticky5: 4.140000ns
signal count4 :  std_logic;
   -- timing of count4: 4.710000ns
signal level4 :  std_logic_vector(39 downto 0);
   -- timing of level4: 5.260000ns
signal sticky_high_4 :  std_logic;
   -- timing of sticky_high_4: 4.120000ns
signal sticky_low_4 :  std_logic;
   -- timing of sticky_low_4: 4.120000ns
signal sticky4 :  std_logic;
   -- timing of sticky4: 5.310000ns
signal count3 :  std_logic;
   -- timing of count3: 5.830000ns
signal level3 :  std_logic_vector(31 downto 0);
   -- timing of level3: 6.380000ns
signal sticky_high_3 :  std_logic;
   -- timing of sticky_high_3: 5.260000ns
signal sticky_low_3 :  std_logic;
   -- timing of sticky_low_3: 0.000000ns
signal sticky3 :  std_logic;
   -- timing of sticky3: 6.400000ns
signal count2 :  std_logic;
   -- timing of count2: 6.940000ns
signal level2 :  std_logic_vector(27 downto 0);
   -- timing of level2: 7.490000ns
signal sticky_high_2 :  std_logic;
   -- timing of sticky_high_2: 6.380000ns
signal sticky_low_2 :  std_logic;
   -- timing of sticky_low_2: 0.000000ns
signal sticky2 :  std_logic;
   -- timing of sticky2: 7.500000ns
signal count1 :  std_logic;
   -- timing of count1: 8.050000ns
signal level1 :  std_logic_vector(25 downto 0);
   -- timing of level1: 8.600000ns
signal sticky_high_1 :  std_logic;
   -- timing of sticky_high_1: 7.490000ns
signal sticky_low_1 :  std_logic;
   -- timing of sticky_low_1: 0.000000ns
signal sticky1 :  std_logic;
   -- timing of sticky1: 8.610000ns
signal count0 :  std_logic;
   -- timing of count0: 9.160000ns
signal level0 :  std_logic_vector(24 downto 0);
   -- timing of level0: 9.710000ns
signal sticky_high_0 :  std_logic;
   -- timing of sticky_high_0: 8.600000ns
signal sticky_low_0 :  std_logic;
   -- timing of sticky_low_0: 0.000000ns
signal sticky0 :  std_logic;
   -- timing of sticky0: 9.720000ns
signal sCount :  std_logic_vector(6 downto 0);
   -- timing of sCount: 9.160000ns
begin
   level7 <= X ;
   sticky7 <= '0' ;
   count6<= '1' when level7(72 downto 9) = (72 downto 9=>'0') else '0';
   level6<= level7(72 downto 0) when count6='0' else level7(8 downto 0) & (63 downto 0 => '0');
   sticky_high_6<= '0';
   sticky_low_6<= '0';
   sticky6<= sticky7 or sticky_high_6 when count6='0' else sticky7 or sticky_low_6;

   count5<= '1' when level6(72 downto 41) = (72 downto 41=>'0') else '0';
   level5<= level6(72 downto 10) when count5='0' else level6(40 downto 0) & (21 downto 0 => '0');
   sticky_high_5<= '0'when level6(9 downto 0) = CONV_STD_LOGIC_VECTOR(0,10) else '1';
   sticky_low_5<= '0';
   sticky5<= sticky6 or sticky_high_5 when count5='0' else sticky6 or sticky_low_5;

   count4<= '1' when level5(62 downto 47) = (62 downto 47=>'0') else '0';
   level4<= level5(62 downto 23) when count4='0' else level5(46 downto 7);
   sticky_high_4<= '0'when level5(22 downto 0) = CONV_STD_LOGIC_VECTOR(0,23) else '1';
   sticky_low_4<= '0'when level5(6 downto 0) = CONV_STD_LOGIC_VECTOR(0,7) else '1';
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
   sCount <= count6 & count5 & count4 & count3 & count2 & count1 & count0;
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
--  approx. input signal timings: X: 10.230000nsY: 10.820000nsCin: 0.000000ns
--  approx. output signal timings: R: 12.140000ns

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
   -- timing of Rtmp: 12.140000ns
begin
   Rtmp <= X + Y + Cin;
   R <= Rtmp;
end architecture;

--------------------------------------------------------------------------------
--                             MXFP_E5M2_to_FP32
--                    (Fix2FP_S_M32_40_to_8_23_comb_uid2)
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
--  approx. output signal timings: O: 12.690000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity MXFP_E5M2_to_FP32 is
    port (I : in  std_logic_vector(72 downto 0);
          O : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of MXFP_E5M2_to_FP32 is
   component IntAdder_73_comb_uid5 is
      port ( X : in  std_logic_vector(72 downto 0);
             Y : in  std_logic_vector(72 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(72 downto 0)   );
   end component;

   component Normalizer_ZStk_73_25_73_comb_uid7 is
      port ( X : in  std_logic_vector(72 downto 0);
             Count : out  std_logic_vector(6 downto 0);
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
signal xoredI :  std_logic_vector(72 downto 0);
   -- timing of xoredI: 0.000000ns
signal bigSign :  std_logic_vector(72 downto 0);
   -- timing of bigSign: 0.000000ns
signal input :  std_logic_vector(72 downto 0);
   -- timing of input: 1.720000ns
signal overflow1 :  std_logic;
   -- timing of overflow1: 0.000000ns
signal sticky1 :  std_logic;
   -- timing of sticky1: 0.000000ns
signal input1 :  std_logic_vector(72 downto 0);
   -- timing of input1: 1.720000ns
signal lzc :  std_logic_vector(6 downto 0);
   -- timing of lzc: 9.160000ns
signal mantissa :  std_logic_vector(24 downto 0);
   -- timing of mantissa: 9.710000ns
signal sticky2 :  std_logic;
   -- timing of sticky2: 9.720000ns
signal sticky :  std_logic;
   -- timing of sticky: 10.270000ns
signal lzcP :  std_logic_vector(7 downto 0);
   -- timing of lzcP: 9.160000ns
signal zero :  std_logic;
   -- timing of zero: 9.710000ns
signal exponentCorrection :  std_logic_vector(7 downto 0);
   -- timing of exponentCorrection: 0.000000ns
signal exponentField :  std_logic_vector(7 downto 0);
   -- timing of exponentField: 10.230000ns
signal MSB2Signal :  std_logic_vector(7 downto 0);
   -- timing of MSB2Signal: 0.000000ns
signal expFrac :  std_logic_vector(31 downto 0);
   -- timing of expFrac: 10.230000ns
signal ulp :  std_logic;
   -- timing of ulp: 9.710000ns
signal roundbit :  std_logic;
   -- timing of roundbit: 9.710000ns
signal roundUp :  std_logic;
   -- timing of roundUp: 10.820000ns
signal roundAddend :  std_logic_vector(32 downto 0);
   -- timing of roundAddend: 10.820000ns
signal zExpFrac :  std_logic_vector(32 downto 0);
   -- timing of zExpFrac: 10.230000ns
signal roundedExpFrac :  std_logic_vector(32 downto 0);
   -- timing of roundedExpFrac: 12.140000ns
signal overflowInRound :  std_logic;
   -- timing of overflowInRound: 12.140000ns
signal finalOverflow :  std_logic;
   -- timing of finalOverflow: 12.140000ns
signal finalExpFrac :  std_logic_vector(30 downto 0);
   -- timing of finalExpFrac: 12.140000ns
signal exc :  std_logic_vector(1 downto 0);
   -- timing of exc: 12.690000ns
signal result :  std_logic_vector(33 downto 0);
   -- timing of result: 12.690000ns
begin
   sign <= I(72);
   xoredI <= I when sign='0' else not I;
   bigSign <= (72 downto 1 => '0') & sign;
   negateAdder: IntAdder_73_comb_uid5
      port map ( Cin => '0',
                 X => bigSign,
                 Y => xoredI,
                 R => input);
   overflow1 <= '0';
   sticky1 <= '0';
   input1 <= input(72 downto 0);
   normer: Normalizer_ZStk_73_25_73_comb_uid7
      port map ( X => input1,
                 Count => lzc,
                 R => mantissa,
                 Sticky => sticky2);
   sticky <= sticky1 or sticky2;
   lzcP <= "0"& lzc ;
   zero <= '1' when lzc >= CONV_STD_LOGIC_VECTOR(73,7)   else '0';
   exponentCorrection <= CONV_STD_LOGIC_VECTOR(167,8);
   exponentField <= exponentCorrection-lzcP;
   MSB2Signal<=CONV_STD_LOGIC_VECTOR(39,8);
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

