--------------------------------------------------------------------------------
--                             normalizer_sgn_70b
--                     (Normalizer_ZO_70_24_70_comb_uid2)
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X OZb
-- Output signals: Count R
--  approx. input signal timings: X: 0.000000nsOZb: 0.000000ns
--  approx. output signal timings: Count: 10.650000nsR: 11.200000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity normalizer_sgn_70b is
    port (X : in  std_logic_vector(69 downto 0);
          OZb : in  std_logic;
          Count : out  std_logic_vector(6 downto 0);
          R : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of normalizer_sgn_70b is
signal level7 :  std_logic_vector(69 downto 0);
   -- timing of level7: 0.000000ns
signal sozb :  std_logic;
   -- timing of sozb: 0.000000ns
signal count6 :  std_logic;
   -- timing of count6: 1.200000ns
signal level6 :  std_logic_vector(69 downto 0);
   -- timing of level6: 1.750000ns
signal count5 :  std_logic;
   -- timing of count5: 2.850000ns
signal level5 :  std_logic_vector(62 downto 0);
   -- timing of level5: 3.400000ns
signal count4 :  std_logic;
   -- timing of count4: 4.440000ns
signal level4 :  std_logic_vector(38 downto 0);
   -- timing of level4: 4.990000ns
signal count3 :  std_logic;
   -- timing of count3: 6.010000ns
signal level3 :  std_logic_vector(30 downto 0);
   -- timing of level3: 6.560000ns
signal count2 :  std_logic;
   -- timing of count2: 7.560000ns
signal level2 :  std_logic_vector(26 downto 0);
   -- timing of level2: 8.110000ns
signal count1 :  std_logic;
   -- timing of count1: 9.110000ns
signal level1 :  std_logic_vector(24 downto 0);
   -- timing of level1: 9.660000ns
signal count0 :  std_logic;
   -- timing of count0: 10.650000ns
signal level0 :  std_logic_vector(23 downto 0);
   -- timing of level0: 11.200000ns
signal sCount :  std_logic_vector(6 downto 0);
   -- timing of sCount: 10.650000ns
begin
   level7 <= X ;
   sozb<= OZb;
   count6<= '1' when level7(69 downto 6) = (69 downto 6=>sozb) else '0';
   level6<= level7(69 downto 0) when count6='0' else level7(5 downto 0) & (63 downto 0 => '0');

   count5<= '1' when level6(69 downto 38) = (69 downto 38=>sozb) else '0';
   level5<= level6(69 downto 7) when count5='0' else level6(37 downto 0) & (24 downto 0 => '0');

   count4<= '1' when level5(62 downto 47) = (62 downto 47=>sozb) else '0';
   level4<= level5(62 downto 24) when count4='0' else level5(46 downto 8);

   count3<= '1' when level4(38 downto 31) = (38 downto 31=>sozb) else '0';
   level3<= level4(38 downto 8) when count3='0' else level4(30 downto 0);

   count2<= '1' when level3(30 downto 27) = (30 downto 27=>sozb) else '0';
   level2<= level3(30 downto 4) when count2='0' else level3(26 downto 0);

   count1<= '1' when level2(26 downto 25) = (26 downto 25=>sozb) else '0';
   level1<= level2(26 downto 2) when count1='0' else level2(24 downto 0);

   count0<= '1' when level1(24 downto 24) = (24 downto 24=>sozb) else '0';
   level0<= level1(24 downto 1) when count0='0' else level1(23 downto 0);

   R <= level0;
   sCount <= count6 & count5 & count4 & count3 & count2 & count1 & count0;
   Count <= sCount;
end architecture;

