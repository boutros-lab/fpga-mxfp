--------------------------------------------------------------------------------
--                               normalizer_39b
--                     (Normalizer_Z_39_24_39_comb_uid2)
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, (2007-2020)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X
-- Output signals: Count R
--  approx. input signal timings: X: 0.000000ns
--  approx. output signal timings: Count: 6.210000nsR: 6.760000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity normalizer_39b is
    port (X : in  std_logic_vector(38 downto 0);
          Count : out  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of normalizer_39b is
signal level6 :  std_logic_vector(38 downto 0);
   -- timing of level6: 0.000000ns
signal count5 :  std_logic;
   -- timing of count5: 0.620000ns
signal level5 :  std_logic_vector(38 downto 0);
   -- timing of level5: 1.170000ns
signal count4 :  std_logic;
   -- timing of count4: 1.760000ns
signal level4 :  std_logic_vector(38 downto 0);
   -- timing of level4: 2.310000ns
signal count3 :  std_logic;
   -- timing of count3: 2.880000ns
signal level3 :  std_logic_vector(30 downto 0);
   -- timing of level3: 3.430000ns
signal count2 :  std_logic;
   -- timing of count2: 3.990000ns
signal level2 :  std_logic_vector(26 downto 0);
   -- timing of level2: 4.540000ns
signal count1 :  std_logic;
   -- timing of count1: 5.100000ns
signal level1 :  std_logic_vector(24 downto 0);
   -- timing of level1: 5.650000ns
signal count0 :  std_logic;
   -- timing of count0: 6.210000ns
signal level0 :  std_logic_vector(23 downto 0);
   -- timing of level0: 6.760000ns
signal sCount :  std_logic_vector(5 downto 0);
   -- timing of sCount: 6.210000ns
begin
   level6 <= X ;
   count5<= '1' when level6(38 downto 7) = (38 downto 7=>'0') else '0';
   level5<= level6(38 downto 0) when count5='0' else level6(6 downto 0) & (31 downto 0 => '0');

   count4<= '1' when level5(38 downto 23) = (38 downto 23=>'0') else '0';
   level4<= level5(38 downto 0) when count4='0' else level5(22 downto 0) & (15 downto 0 => '0');

   count3<= '1' when level4(38 downto 31) = (38 downto 31=>'0') else '0';
   level3<= level4(38 downto 8) when count3='0' else level4(30 downto 0);

   count2<= '1' when level3(30 downto 27) = (30 downto 27=>'0') else '0';
   level2<= level3(30 downto 4) when count2='0' else level3(26 downto 0);

   count1<= '1' when level2(26 downto 25) = (26 downto 25=>'0') else '0';
   level1<= level2(26 downto 2) when count1='0' else level2(24 downto 0);

   count0<= '1' when level1(24 downto 24) = (24 downto 24=>'0') else '0';
   level0<= level1(24 downto 1) when count0='0' else level1(23 downto 0);

   R <= level0;
   sCount <= count5 & count4 & count3 & count2 & count1 & count0;
   Count <= sCount;
end architecture;

