--------------------------------------------------------------------------------
--                          IntAdder_73_Freq800_uid5
-- VHDL generated for StratixV @ 800MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2016)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles
-- Clock period (ns): 1.25
-- Target frequency (MHz): 800
-- Input signals: X Y Cin
-- Output signals: R
--  approx. input signal timings: X: (c0, 0.000000ns)Y: (c0, 0.000000ns)Cin: (c0, 0.000000ns)
--  approx. output signal timings: R: (c2, 0.713000ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_73_Freq800_uid5 is
    port (clk : in std_logic;
          X : in  std_logic_vector(72 downto 0);
          Y : in  std_logic_vector(72 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of IntAdder_73_Freq800_uid5 is
signal Cin_0, Cin_0_d1 :  std_logic;
   -- timing of Cin_0: (c0, 0.000000ns)
signal X_0, X_0_d1 :  std_logic_vector(31 downto 0);
   -- timing of X_0: (c0, 0.000000ns)
signal Y_0, Y_0_d1 :  std_logic_vector(31 downto 0);
   -- timing of Y_0: (c0, 0.000000ns)
signal S_0 :  std_logic_vector(31 downto 0);
   -- timing of S_0: (c1, 0.016000ns)
signal R_0, R_0_d1 :  std_logic_vector(30 downto 0);
   -- timing of R_0: (c1, 0.016000ns)
signal Cin_1, Cin_1_d1 :  std_logic;
   -- timing of Cin_1: (c1, 0.016000ns)
signal X_1, X_1_d1, X_1_d2 :  std_logic_vector(31 downto 0);
   -- timing of X_1: (c0, 0.000000ns)
signal Y_1, Y_1_d1, Y_1_d2 :  std_logic_vector(31 downto 0);
   -- timing of Y_1: (c0, 0.000000ns)
signal S_1 :  std_logic_vector(31 downto 0);
   -- timing of S_1: (c2, 0.032000ns)
signal R_1 :  std_logic_vector(30 downto 0);
   -- timing of R_1: (c2, 0.032000ns)
signal Cin_2 :  std_logic;
   -- timing of Cin_2: (c2, 0.032000ns)
signal X_2, X_2_d1, X_2_d2 :  std_logic_vector(11 downto 0);
   -- timing of X_2: (c0, 0.000000ns)
signal Y_2, Y_2_d1, Y_2_d2 :  std_logic_vector(11 downto 0);
   -- timing of Y_2: (c0, 0.000000ns)
signal S_2 :  std_logic_vector(11 downto 0);
   -- timing of S_2: (c2, 0.713000ns)
signal R_2 :  std_logic_vector(10 downto 0);
   -- timing of R_2: (c2, 0.713000ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            Cin_0_d1 <=  Cin_0;
            X_0_d1 <=  X_0;
            Y_0_d1 <=  Y_0;
            R_0_d1 <=  R_0;
            Cin_1_d1 <=  Cin_1;
            X_1_d1 <=  X_1;
            X_1_d2 <=  X_1_d1;
            Y_1_d1 <=  Y_1;
            Y_1_d2 <=  Y_1_d1;
            X_2_d1 <=  X_2;
            X_2_d2 <=  X_2_d1;
            Y_2_d1 <=  Y_2;
            Y_2_d2 <=  Y_2_d1;
         end if;
      end process;
   Cin_0 <= Cin;
   X_0 <= '0' & X(30 downto 0);
   Y_0 <= '0' & Y(30 downto 0);
   S_0 <= X_0_d1 + Y_0_d1 + Cin_0_d1;
   R_0 <= S_0(30 downto 0);
   Cin_1 <= S_0(31);
   X_1 <= '0' & X(61 downto 31);
   Y_1 <= '0' & Y(61 downto 31);
   S_1 <= X_1_d2 + Y_1_d2 + Cin_1_d1;
   R_1 <= S_1(30 downto 0);
   Cin_2 <= S_1(31);
   X_2 <= '0' & X(72 downto 62);
   Y_2 <= '0' & Y(72 downto 62);
   S_2 <= X_2_d2 + Y_2_d2 + Cin_2;
   R_2 <= S_2(10 downto 0);
   R <= R_2 & R_1 & R_0_d1 ;
end architecture;

--------------------------------------------------------------------------------
--                   Normalizer_ZStk_73_25_73_Freq800_uid7
-- VHDL generated for StratixV @ 800MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- Pipeline depth: 11 cycles
-- Clock period (ns): 1.25
-- Target frequency (MHz): 800
-- Input signals: X
-- Output signals: Count R Sticky
--  approx. input signal timings: X: (c2, 0.713000ns)
--  approx. output signal timings: Count: (c11, 0.010000ns)R: (c11, 0.443000ns)Sticky: (c11, 0.758000ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity Normalizer_ZStk_73_25_73_Freq800_uid7 is
    port (clk : in std_logic;
          X : in  std_logic_vector(72 downto 0);
          Count : out  std_logic_vector(6 downto 0);
          R : out  std_logic_vector(24 downto 0);
          Sticky : out  std_logic   );
end entity;

architecture arch of Normalizer_ZStk_73_25_73_Freq800_uid7 is
signal level7, level7_d1, level7_d2 :  std_logic_vector(72 downto 0);
   -- timing of level7: (c2, 0.713000ns)
signal sticky7, sticky7_d1, sticky7_d2, sticky7_d3, sticky7_d4 :  std_logic;
   -- timing of sticky7: (c0, 0.000000ns)
signal count6, count6_d1, count6_d2, count6_d3, count6_d4, count6_d5, count6_d6, count6_d7 :  std_logic;
   -- timing of count6: (c4, 0.043000ns)
signal level6, level6_d1 :  std_logic_vector(72 downto 0);
   -- timing of level6: (c4, 0.476000ns)
signal sticky_high_6, sticky_high_6_d1, sticky_high_6_d2, sticky_high_6_d3, sticky_high_6_d4 :  std_logic;
   -- timing of sticky_high_6: (c0, 0.000000ns)
signal sticky_low_6, sticky_low_6_d1, sticky_low_6_d2, sticky_low_6_d3, sticky_low_6_d4 :  std_logic;
   -- timing of sticky_low_6: (c0, 0.000000ns)
signal sticky6, sticky6_d1, sticky6_d2 :  std_logic;
   -- timing of sticky6: (c4, 0.791000ns)
signal count5, count5_d1, count5_d2, count5_d3, count5_d4, count5_d5, count5_d6 :  std_logic;
   -- timing of count5: (c5, 0.515000ns)
signal level5, level5_d1, level5_d2 :  std_logic_vector(62 downto 0);
   -- timing of level5: (c5, 0.948000ns)
signal sticky_high_5, sticky_high_5_d1, sticky_high_5_d2 :  std_logic;
   -- timing of sticky_high_5: (c4, 0.476000ns)
signal sticky_low_5, sticky_low_5_d1, sticky_low_5_d2, sticky_low_5_d3, sticky_low_5_d4, sticky_low_5_d5, sticky_low_5_d6 :  std_logic;
   -- timing of sticky_low_5: (c0, 0.000000ns)
signal sticky5, sticky5_d1 :  std_logic;
   -- timing of sticky5: (c6, 0.213000ns)
signal count4, count4_d1, count4_d2, count4_d3, count4_d4, count4_d5 :  std_logic;
   -- timing of count4: (c6, 0.690000ns)
signal level4, level4_d1 :  std_logic_vector(39 downto 0);
   -- timing of level4: (c7, 0.029000ns)
signal sticky_high_4, sticky_high_4_d1, sticky_high_4_d2 :  std_logic;
   -- timing of sticky_high_4: (c5, 0.948000ns)
signal sticky_low_4, sticky_low_4_d1, sticky_low_4_d2 :  std_logic;
   -- timing of sticky_low_4: (c5, 0.948000ns)
signal sticky4, sticky4_d1 :  std_logic;
   -- timing of sticky4: (c7, 0.663000ns)
signal count3, count3_d1, count3_d2, count3_d3, count3_d4 :  std_logic;
   -- timing of count3: (c7, 0.821000ns)
signal level3, level3_d1 :  std_logic_vector(31 downto 0);
   -- timing of level3: (c8, 0.160000ns)
signal sticky_high_3, sticky_high_3_d1 :  std_logic;
   -- timing of sticky_high_3: (c7, 0.029000ns)
signal sticky_low_3, sticky_low_3_d1, sticky_low_3_d2, sticky_low_3_d3, sticky_low_3_d4, sticky_low_3_d5, sticky_low_3_d6, sticky_low_3_d7, sticky_low_3_d8 :  std_logic;
   -- timing of sticky_low_3: (c0, 0.000000ns)
signal sticky3, sticky3_d1 :  std_logic;
   -- timing of sticky3: (c8, 0.519000ns)
signal count2, count2_d1, count2_d2, count2_d3 :  std_logic;
   -- timing of count2: (c8, 0.930000ns)
signal level2, level2_d1 :  std_logic_vector(27 downto 0);
   -- timing of level2: (c9, 0.269000ns)
signal sticky_high_2, sticky_high_2_d1 :  std_logic;
   -- timing of sticky_high_2: (c8, 0.160000ns)
signal sticky_low_2, sticky_low_2_d1, sticky_low_2_d2, sticky_low_2_d3, sticky_low_2_d4, sticky_low_2_d5, sticky_low_2_d6, sticky_low_2_d7, sticky_low_2_d8, sticky_low_2_d9 :  std_logic;
   -- timing of sticky_low_2: (c0, 0.000000ns)
signal sticky2, sticky2_d1 :  std_logic;
   -- timing of sticky2: (c9, 0.606000ns)
signal count1, count1_d1, count1_d2 :  std_logic;
   -- timing of count1: (c9, 1.017000ns)
signal level1, level1_d1 :  std_logic_vector(25 downto 0);
   -- timing of level1: (c10, 0.356000ns)
signal sticky_high_1, sticky_high_1_d1 :  std_logic;
   -- timing of sticky_high_1: (c9, 0.269000ns)
signal sticky_low_1, sticky_low_1_d1, sticky_low_1_d2, sticky_low_1_d3, sticky_low_1_d4, sticky_low_1_d5, sticky_low_1_d6, sticky_low_1_d7, sticky_low_1_d8, sticky_low_1_d9, sticky_low_1_d10 :  std_logic;
   -- timing of sticky_low_1: (c0, 0.000000ns)
signal sticky1, sticky1_d1 :  std_logic;
   -- timing of sticky1: (c10, 0.671000ns)
signal count0 :  std_logic;
   -- timing of count0: (c11, 0.010000ns)
signal level0 :  std_logic_vector(24 downto 0);
   -- timing of level0: (c11, 0.443000ns)
signal sticky_high_0, sticky_high_0_d1 :  std_logic;
   -- timing of sticky_high_0: (c10, 0.356000ns)
signal sticky_low_0, sticky_low_0_d1, sticky_low_0_d2, sticky_low_0_d3, sticky_low_0_d4, sticky_low_0_d5, sticky_low_0_d6, sticky_low_0_d7, sticky_low_0_d8, sticky_low_0_d9, sticky_low_0_d10, sticky_low_0_d11 :  std_logic;
   -- timing of sticky_low_0: (c0, 0.000000ns)
signal sticky0 :  std_logic;
   -- timing of sticky0: (c11, 0.758000ns)
signal sCount :  std_logic_vector(6 downto 0);
   -- timing of sCount: (c11, 0.010000ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level7_d1 <=  level7;
            level7_d2 <=  level7_d1;
            sticky7_d1 <=  sticky7;
            sticky7_d2 <=  sticky7_d1;
            sticky7_d3 <=  sticky7_d2;
            sticky7_d4 <=  sticky7_d3;
            count6_d1 <=  count6;
            count6_d2 <=  count6_d1;
            count6_d3 <=  count6_d2;
            count6_d4 <=  count6_d3;
            count6_d5 <=  count6_d4;
            count6_d6 <=  count6_d5;
            count6_d7 <=  count6_d6;
            level6_d1 <=  level6;
            sticky_high_6_d1 <=  sticky_high_6;
            sticky_high_6_d2 <=  sticky_high_6_d1;
            sticky_high_6_d3 <=  sticky_high_6_d2;
            sticky_high_6_d4 <=  sticky_high_6_d3;
            sticky_low_6_d1 <=  sticky_low_6;
            sticky_low_6_d2 <=  sticky_low_6_d1;
            sticky_low_6_d3 <=  sticky_low_6_d2;
            sticky_low_6_d4 <=  sticky_low_6_d3;
            sticky6_d1 <=  sticky6;
            sticky6_d2 <=  sticky6_d1;
            count5_d1 <=  count5;
            count5_d2 <=  count5_d1;
            count5_d3 <=  count5_d2;
            count5_d4 <=  count5_d3;
            count5_d5 <=  count5_d4;
            count5_d6 <=  count5_d5;
            level5_d1 <=  level5;
            level5_d2 <=  level5_d1;
            sticky_high_5_d1 <=  sticky_high_5;
            sticky_high_5_d2 <=  sticky_high_5_d1;
            sticky_low_5_d1 <=  sticky_low_5;
            sticky_low_5_d2 <=  sticky_low_5_d1;
            sticky_low_5_d3 <=  sticky_low_5_d2;
            sticky_low_5_d4 <=  sticky_low_5_d3;
            sticky_low_5_d5 <=  sticky_low_5_d4;
            sticky_low_5_d6 <=  sticky_low_5_d5;
            sticky5_d1 <=  sticky5;
            count4_d1 <=  count4;
            count4_d2 <=  count4_d1;
            count4_d3 <=  count4_d2;
            count4_d4 <=  count4_d3;
            count4_d5 <=  count4_d4;
            level4_d1 <=  level4;
            sticky_high_4_d1 <=  sticky_high_4;
            sticky_high_4_d2 <=  sticky_high_4_d1;
            sticky_low_4_d1 <=  sticky_low_4;
            sticky_low_4_d2 <=  sticky_low_4_d1;
            sticky4_d1 <=  sticky4;
            count3_d1 <=  count3;
            count3_d2 <=  count3_d1;
            count3_d3 <=  count3_d2;
            count3_d4 <=  count3_d3;
            level3_d1 <=  level3;
            sticky_high_3_d1 <=  sticky_high_3;
            sticky_low_3_d1 <=  sticky_low_3;
            sticky_low_3_d2 <=  sticky_low_3_d1;
            sticky_low_3_d3 <=  sticky_low_3_d2;
            sticky_low_3_d4 <=  sticky_low_3_d3;
            sticky_low_3_d5 <=  sticky_low_3_d4;
            sticky_low_3_d6 <=  sticky_low_3_d5;
            sticky_low_3_d7 <=  sticky_low_3_d6;
            sticky_low_3_d8 <=  sticky_low_3_d7;
            sticky3_d1 <=  sticky3;
            count2_d1 <=  count2;
            count2_d2 <=  count2_d1;
            count2_d3 <=  count2_d2;
            level2_d1 <=  level2;
            sticky_high_2_d1 <=  sticky_high_2;
            sticky_low_2_d1 <=  sticky_low_2;
            sticky_low_2_d2 <=  sticky_low_2_d1;
            sticky_low_2_d3 <=  sticky_low_2_d2;
            sticky_low_2_d4 <=  sticky_low_2_d3;
            sticky_low_2_d5 <=  sticky_low_2_d4;
            sticky_low_2_d6 <=  sticky_low_2_d5;
            sticky_low_2_d7 <=  sticky_low_2_d6;
            sticky_low_2_d8 <=  sticky_low_2_d7;
            sticky_low_2_d9 <=  sticky_low_2_d8;
            sticky2_d1 <=  sticky2;
            count1_d1 <=  count1;
            count1_d2 <=  count1_d1;
            level1_d1 <=  level1;
            sticky_high_1_d1 <=  sticky_high_1;
            sticky_low_1_d1 <=  sticky_low_1;
            sticky_low_1_d2 <=  sticky_low_1_d1;
            sticky_low_1_d3 <=  sticky_low_1_d2;
            sticky_low_1_d4 <=  sticky_low_1_d3;
            sticky_low_1_d5 <=  sticky_low_1_d4;
            sticky_low_1_d6 <=  sticky_low_1_d5;
            sticky_low_1_d7 <=  sticky_low_1_d6;
            sticky_low_1_d8 <=  sticky_low_1_d7;
            sticky_low_1_d9 <=  sticky_low_1_d8;
            sticky_low_1_d10 <=  sticky_low_1_d9;
            sticky1_d1 <=  sticky1;
            sticky_high_0_d1 <=  sticky_high_0;
            sticky_low_0_d1 <=  sticky_low_0;
            sticky_low_0_d2 <=  sticky_low_0_d1;
            sticky_low_0_d3 <=  sticky_low_0_d2;
            sticky_low_0_d4 <=  sticky_low_0_d3;
            sticky_low_0_d5 <=  sticky_low_0_d4;
            sticky_low_0_d6 <=  sticky_low_0_d5;
            sticky_low_0_d7 <=  sticky_low_0_d6;
            sticky_low_0_d8 <=  sticky_low_0_d7;
            sticky_low_0_d9 <=  sticky_low_0_d8;
            sticky_low_0_d10 <=  sticky_low_0_d9;
            sticky_low_0_d11 <=  sticky_low_0_d10;
         end if;
      end process;
   level7 <= X ;
   sticky7 <= '0' ;
   count6<= '1' when level7_d2(72 downto 9) = (72 downto 9=>'0') else '0';
   level6<= level7_d2(72 downto 0) when count6='0' else level7_d2(8 downto 0) & (63 downto 0 => '0');
   sticky_high_6<= '0';
   sticky_low_6<= '0';
   sticky6<= sticky7_d4 or sticky_high_6_d4 when count6='0' else sticky7_d4 or sticky_low_6_d4;

   count5<= '1' when level6_d1(72 downto 41) = (72 downto 41=>'0') else '0';
   level5<= level6_d1(72 downto 10) when count5='0' else level6_d1(40 downto 0) & (21 downto 0 => '0');
   sticky_high_5<= '0'when level6(9 downto 0) = CONV_STD_LOGIC_VECTOR(0,10) else '1';
   sticky_low_5<= '0';
   sticky5<= sticky6_d2 or sticky_high_5_d2 when count5_d1='0' else sticky6_d2 or sticky_low_5_d6;

   count4<= '1' when level5_d1(62 downto 47) = (62 downto 47=>'0') else '0';
   level4<= level5_d2(62 downto 23) when count4_d1='0' else level5_d2(46 downto 7);
   sticky_high_4<= '0'when level5(22 downto 0) = CONV_STD_LOGIC_VECTOR(0,23) else '1';
   sticky_low_4<= '0'when level5(6 downto 0) = CONV_STD_LOGIC_VECTOR(0,7) else '1';
   sticky4<= sticky5_d1 or sticky_high_4_d2 when count4_d1='0' else sticky5_d1 or sticky_low_4_d2;

   count3<= '1' when level4(39 downto 32) = (39 downto 32=>'0') else '0';
   level3<= level4_d1(39 downto 8) when count3_d1='0' else level4_d1(31 downto 0);
   sticky_high_3<= '0'when level4(7 downto 0) = CONV_STD_LOGIC_VECTOR(0,8) else '1';
   sticky_low_3<= '0';
   sticky3<= sticky4_d1 or sticky_high_3_d1 when count3_d1='0' else sticky4_d1 or sticky_low_3_d8;

   count2<= '1' when level3(31 downto 28) = (31 downto 28=>'0') else '0';
   level2<= level3_d1(31 downto 4) when count2_d1='0' else level3_d1(27 downto 0);
   sticky_high_2<= '0'when level3(3 downto 0) = CONV_STD_LOGIC_VECTOR(0,4) else '1';
   sticky_low_2<= '0';
   sticky2<= sticky3_d1 or sticky_high_2_d1 when count2_d1='0' else sticky3_d1 or sticky_low_2_d9;

   count1<= '1' when level2(27 downto 26) = (27 downto 26=>'0') else '0';
   level1<= level2_d1(27 downto 2) when count1_d1='0' else level2_d1(25 downto 0);
   sticky_high_1<= '0'when level2(1 downto 0) = CONV_STD_LOGIC_VECTOR(0,2) else '1';
   sticky_low_1<= '0';
   sticky1<= sticky2_d1 or sticky_high_1_d1 when count1_d1='0' else sticky2_d1 or sticky_low_1_d10;

   count0<= '1' when level1_d1(25 downto 25) = (25 downto 25=>'0') else '0';
   level0<= level1_d1(25 downto 1) when count0='0' else level1_d1(24 downto 0);
   sticky_high_0<= '0'when level1(0 downto 0) = CONV_STD_LOGIC_VECTOR(0,1) else '1';
   sticky_low_0<= '0';
   sticky0<= sticky1_d1 or sticky_high_0_d1 when count0='0' else sticky1_d1 or sticky_low_0_d11;

   R <= level0;
   sCount <= count6_d7 & count5_d6 & count4_d5 & count3_d4 & count2_d3 & count1_d2 & count0;
   Count <= sCount;
   Sticky <= sticky0;
end architecture;

--------------------------------------------------------------------------------
--                         IntAdder_33_Freq800_uid10
-- VHDL generated for StratixV @ 800MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2016)
--------------------------------------------------------------------------------
-- Pipeline depth: 13 cycles
-- Clock period (ns): 1.25
-- Target frequency (MHz): 800
-- Input signals: X Y Cin
-- Output signals: R
--  approx. input signal timings: X: (c11, 0.443000ns)Y: (c12, 0.530000ns)Cin: (c0, 0.000000ns)
--  approx. output signal timings: R: (c13, 0.908000ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_33_Freq800_uid10 is
    port (clk : in std_logic;
          X : in  std_logic_vector(32 downto 0);
          Y : in  std_logic_vector(32 downto 0);
          Cin : in  std_logic;
          R : out  std_logic_vector(32 downto 0)   );
end entity;

architecture arch of IntAdder_33_Freq800_uid10 is
signal Cin_0, Cin_0_d1, Cin_0_d2, Cin_0_d3, Cin_0_d4, Cin_0_d5, Cin_0_d6, Cin_0_d7, Cin_0_d8, Cin_0_d9, Cin_0_d10, Cin_0_d11, Cin_0_d12, Cin_0_d13 :  std_logic;
   -- timing of Cin_0: (c0, 0.000000ns)
signal X_0, X_0_d1, X_0_d2 :  std_logic_vector(9 downto 0);
   -- timing of X_0: (c11, 0.443000ns)
signal Y_0, Y_0_d1 :  std_logic_vector(9 downto 0);
   -- timing of Y_0: (c12, 0.530000ns)
signal S_0 :  std_logic_vector(9 downto 0);
   -- timing of S_0: (c13, 0.095000ns)
signal R_0 :  std_logic_vector(8 downto 0);
   -- timing of R_0: (c13, 0.095000ns)
signal Cin_1 :  std_logic;
   -- timing of Cin_1: (c13, 0.095000ns)
signal X_1, X_1_d1, X_1_d2 :  std_logic_vector(24 downto 0);
   -- timing of X_1: (c11, 0.443000ns)
signal Y_1, Y_1_d1 :  std_logic_vector(24 downto 0);
   -- timing of Y_1: (c12, 0.530000ns)
signal S_1 :  std_logic_vector(24 downto 0);
   -- timing of S_1: (c13, 0.908000ns)
signal R_1 :  std_logic_vector(23 downto 0);
   -- timing of R_1: (c13, 0.908000ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            Cin_0_d1 <=  Cin_0;
            Cin_0_d2 <=  Cin_0_d1;
            Cin_0_d3 <=  Cin_0_d2;
            Cin_0_d4 <=  Cin_0_d3;
            Cin_0_d5 <=  Cin_0_d4;
            Cin_0_d6 <=  Cin_0_d5;
            Cin_0_d7 <=  Cin_0_d6;
            Cin_0_d8 <=  Cin_0_d7;
            Cin_0_d9 <=  Cin_0_d8;
            Cin_0_d10 <=  Cin_0_d9;
            Cin_0_d11 <=  Cin_0_d10;
            Cin_0_d12 <=  Cin_0_d11;
            Cin_0_d13 <=  Cin_0_d12;
            X_0_d1 <=  X_0;
            X_0_d2 <=  X_0_d1;
            Y_0_d1 <=  Y_0;
            X_1_d1 <=  X_1;
            X_1_d2 <=  X_1_d1;
            Y_1_d1 <=  Y_1;
         end if;
      end process;
   Cin_0 <= Cin;
   X_0 <= '0' & X(8 downto 0);
   Y_0 <= '0' & Y(8 downto 0);
   S_0 <= X_0_d2 + Y_0_d1 + Cin_0_d13;
   R_0 <= S_0(8 downto 0);
   Cin_1 <= S_0(9);
   X_1 <= '0' & X(32 downto 9);
   Y_1 <= '0' & Y(32 downto 9);
   S_1 <= X_1_d2 + Y_1_d1 + Cin_1;
   R_1 <= S_1(23 downto 0);
   R <= R_1 & R_0 ;
end architecture;

--------------------------------------------------------------------------------
--                             MXFP_E5M2_to_FP32
--                   (Fix2FP_S_M32_40_to_8_23_Freq800_uid2)
-- VHDL generated for StratixV @ 800MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2026)
--------------------------------------------------------------------------------
-- Pipeline depth: 14 cycles
-- Clock period (ns): 1.25
-- Target frequency (MHz): 800
-- Input signals: I
-- Output signals: O
--  approx. input signal timings: I: (c0, 0.000000ns)
--  approx. output signal timings: O: (c14, 0.247000ns)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity MXFP_E5M2_to_FP32 is
    port (clk : in std_logic;
          I : in  std_logic_vector(72 downto 0);
          O : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of MXFP_E5M2_to_FP32 is
   component IntAdder_73_Freq800_uid5 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(72 downto 0);
             Y : in  std_logic_vector(72 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(72 downto 0)   );
   end component;

   component Normalizer_ZStk_73_25_73_Freq800_uid7 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(72 downto 0);
             Count : out  std_logic_vector(6 downto 0);
             R : out  std_logic_vector(24 downto 0);
             Sticky : out  std_logic   );
   end component;

   component IntAdder_33_Freq800_uid10 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(32 downto 0);
             Y : in  std_logic_vector(32 downto 0);
             Cin : in  std_logic;
             R : out  std_logic_vector(32 downto 0)   );
   end component;

signal sign, sign_d1, sign_d2, sign_d3, sign_d4, sign_d5, sign_d6, sign_d7, sign_d8, sign_d9, sign_d10, sign_d11, sign_d12, sign_d13, sign_d14 :  std_logic;
   -- timing of sign: (c0, 0.000000ns)
signal xoredI :  std_logic_vector(72 downto 0);
   -- timing of xoredI: (c0, 0.000000ns)
signal bigSign :  std_logic_vector(72 downto 0);
   -- timing of bigSign: (c0, 0.000000ns)
signal input :  std_logic_vector(72 downto 0);
   -- timing of input: (c2, 0.713000ns)
signal overflow1, overflow1_d1, overflow1_d2, overflow1_d3, overflow1_d4, overflow1_d5, overflow1_d6, overflow1_d7, overflow1_d8, overflow1_d9, overflow1_d10, overflow1_d11, overflow1_d12, overflow1_d13 :  std_logic;
   -- timing of overflow1: (c0, 0.000000ns)
signal sticky1, sticky1_d1, sticky1_d2, sticky1_d3, sticky1_d4, sticky1_d5, sticky1_d6, sticky1_d7, sticky1_d8, sticky1_d9, sticky1_d10, sticky1_d11, sticky1_d12 :  std_logic;
   -- timing of sticky1: (c0, 0.000000ns)
signal input1 :  std_logic_vector(72 downto 0);
   -- timing of input1: (c2, 0.713000ns)
signal lzc :  std_logic_vector(6 downto 0);
   -- timing of lzc: (c11, 0.010000ns)
signal mantissa :  std_logic_vector(24 downto 0);
   -- timing of mantissa: (c11, 0.443000ns)
signal sticky2, sticky2_d1 :  std_logic;
   -- timing of sticky2: (c11, 0.758000ns)
signal sticky :  std_logic;
   -- timing of sticky: (c12, 0.097000ns)
signal lzcP :  std_logic_vector(7 downto 0);
   -- timing of lzcP: (c11, 0.010000ns)
signal zero, zero_d1, zero_d2, zero_d3 :  std_logic;
   -- timing of zero: (c11, 0.443000ns)
signal exponentCorrection, exponentCorrection_d1, exponentCorrection_d2, exponentCorrection_d3, exponentCorrection_d4, exponentCorrection_d5, exponentCorrection_d6, exponentCorrection_d7, exponentCorrection_d8, exponentCorrection_d9, exponentCorrection_d10, exponentCorrection_d11 :  std_logic_vector(7 downto 0);
   -- timing of exponentCorrection: (c0, 0.000000ns)
signal exponentField :  std_logic_vector(7 downto 0);
   -- timing of exponentField: (c11, 0.438000ns)
signal MSB2Signal :  std_logic_vector(7 downto 0);
   -- timing of MSB2Signal: (c0, 0.000000ns)
signal expFrac :  std_logic_vector(31 downto 0);
   -- timing of expFrac: (c11, 0.443000ns)
signal ulp, ulp_d1 :  std_logic;
   -- timing of ulp: (c11, 0.443000ns)
signal roundbit, roundbit_d1 :  std_logic;
   -- timing of roundbit: (c11, 0.443000ns)
signal roundUp :  std_logic;
   -- timing of roundUp: (c12, 0.530000ns)
signal roundAddend :  std_logic_vector(32 downto 0);
   -- timing of roundAddend: (c12, 0.530000ns)
signal zExpFrac :  std_logic_vector(32 downto 0);
   -- timing of zExpFrac: (c11, 0.443000ns)
signal roundedExpFrac :  std_logic_vector(32 downto 0);
   -- timing of roundedExpFrac: (c13, 0.908000ns)
signal overflowInRound :  std_logic;
   -- timing of overflowInRound: (c13, 0.908000ns)
signal finalOverflow, finalOverflow_d1 :  std_logic;
   -- timing of finalOverflow: (c13, 0.908000ns)
signal finalExpFrac, finalExpFrac_d1 :  std_logic_vector(30 downto 0);
   -- timing of finalExpFrac: (c13, 0.908000ns)
signal exc :  std_logic_vector(1 downto 0);
   -- timing of exc: (c14, 0.247000ns)
signal result :  std_logic_vector(33 downto 0);
   -- timing of result: (c14, 0.247000ns)
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            sign_d1 <=  sign;
            sign_d2 <=  sign_d1;
            sign_d3 <=  sign_d2;
            sign_d4 <=  sign_d3;
            sign_d5 <=  sign_d4;
            sign_d6 <=  sign_d5;
            sign_d7 <=  sign_d6;
            sign_d8 <=  sign_d7;
            sign_d9 <=  sign_d8;
            sign_d10 <=  sign_d9;
            sign_d11 <=  sign_d10;
            sign_d12 <=  sign_d11;
            sign_d13 <=  sign_d12;
            sign_d14 <=  sign_d13;
            overflow1_d1 <=  overflow1;
            overflow1_d2 <=  overflow1_d1;
            overflow1_d3 <=  overflow1_d2;
            overflow1_d4 <=  overflow1_d3;
            overflow1_d5 <=  overflow1_d4;
            overflow1_d6 <=  overflow1_d5;
            overflow1_d7 <=  overflow1_d6;
            overflow1_d8 <=  overflow1_d7;
            overflow1_d9 <=  overflow1_d8;
            overflow1_d10 <=  overflow1_d9;
            overflow1_d11 <=  overflow1_d10;
            overflow1_d12 <=  overflow1_d11;
            overflow1_d13 <=  overflow1_d12;
            sticky1_d1 <=  sticky1;
            sticky1_d2 <=  sticky1_d1;
            sticky1_d3 <=  sticky1_d2;
            sticky1_d4 <=  sticky1_d3;
            sticky1_d5 <=  sticky1_d4;
            sticky1_d6 <=  sticky1_d5;
            sticky1_d7 <=  sticky1_d6;
            sticky1_d8 <=  sticky1_d7;
            sticky1_d9 <=  sticky1_d8;
            sticky1_d10 <=  sticky1_d9;
            sticky1_d11 <=  sticky1_d10;
            sticky1_d12 <=  sticky1_d11;
            sticky2_d1 <=  sticky2;
            zero_d1 <=  zero;
            zero_d2 <=  zero_d1;
            zero_d3 <=  zero_d2;
            exponentCorrection_d1 <=  exponentCorrection;
            exponentCorrection_d2 <=  exponentCorrection_d1;
            exponentCorrection_d3 <=  exponentCorrection_d2;
            exponentCorrection_d4 <=  exponentCorrection_d3;
            exponentCorrection_d5 <=  exponentCorrection_d4;
            exponentCorrection_d6 <=  exponentCorrection_d5;
            exponentCorrection_d7 <=  exponentCorrection_d6;
            exponentCorrection_d8 <=  exponentCorrection_d7;
            exponentCorrection_d9 <=  exponentCorrection_d8;
            exponentCorrection_d10 <=  exponentCorrection_d9;
            exponentCorrection_d11 <=  exponentCorrection_d10;
            ulp_d1 <=  ulp;
            roundbit_d1 <=  roundbit;
            finalOverflow_d1 <=  finalOverflow;
            finalExpFrac_d1 <=  finalExpFrac;
         end if;
      end process;
   sign <= I(72);
   xoredI <= I when sign='0' else not I;
   bigSign <= (72 downto 1 => '0') & sign;
   negateAdder: IntAdder_73_Freq800_uid5
      port map ( clk  => clk,
                 Cin => '0',
                 X => bigSign,
                 Y => xoredI,
                 R => input);
   overflow1 <= '0';
   sticky1 <= '0';
   input1 <= input(72 downto 0);
   normer: Normalizer_ZStk_73_25_73_Freq800_uid7
      port map ( clk  => clk,
                 X => input1,
                 Count => lzc,
                 R => mantissa,
                 Sticky => sticky2);
   sticky <= sticky1_d12 or sticky2_d1;
   lzcP <= "0"& lzc ;
   zero <= '1' when lzc >= CONV_STD_LOGIC_VECTOR(73,7)   else '0';
   exponentCorrection <= CONV_STD_LOGIC_VECTOR(167,8);
   exponentField <= exponentCorrection_d11-lzcP;
   MSB2Signal<=CONV_STD_LOGIC_VECTOR(39,8);
   expFrac <= exponentField & (mantissa(23 downto 0)) ;
   ulp <=  mantissa(1);
   roundbit <=  mantissa(0);
   roundUp <=  '1' when roundbit_d1='1' and (sticky='1' or (ulp_d1='1' and sticky='0')) else '0';
   roundAddend <= "00000000000000000000000000000000" & roundUp;
   zExpFrac <= '0' & expFrac;
   roundingAdder: IntAdder_33_Freq800_uid10
      port map ( clk  => clk,
                 Cin => '0',
                 X => zExpFrac,
                 Y => roundAddend,
                 R => roundedExpFrac);
   overflowInRound <= roundedExpFrac(32);
   finalOverflow <= overflow1_d13 or overflowInRound;
   finalExpFrac <=  roundedExpFrac(31 downto 1);
   exc <=  "10" when finalOverflow_d1='1' else "00" when zero_d3='1' else "01";
   result <=  exc & sign_d14 & finalExpFrac_d1;
   O <= result;
end architecture;

