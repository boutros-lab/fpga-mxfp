--------------------------------------------------------------------------------
--                               normalizer_24b
--                     (Normalizer_Z_24_24_24_comb_uid2)
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
--  approx. output signal timings: Count: 5.040000nsR: 5.590000ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity normalizer_24b is
    port (X : in  std_logic_vector(23 downto 0);
          Count : out  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(23 downto 0)   );
end entity;

architecture arch of normalizer_24b is
signal level5 :  std_logic_vector(23 downto 0);
   -- timing of level5: 0.000000ns
signal count4 :  std_logic;
   -- timing of count4: 0.590000ns
signal level4 :  std_logic_vector(23 downto 0);
   -- timing of level4: 1.140000ns
signal count3 :  std_logic;
   -- timing of count3: 1.710000ns
signal level3 :  std_logic_vector(23 downto 0);
   -- timing of level3: 2.260000ns
signal count2 :  std_logic;
   -- timing of count2: 2.820000ns
signal level2 :  std_logic_vector(23 downto 0);
   -- timing of level2: 3.370000ns
signal count1 :  std_logic;
   -- timing of count1: 3.930000ns
signal level1 :  std_logic_vector(23 downto 0);
   -- timing of level1: 4.480000ns
signal count0 :  std_logic;
   -- timing of count0: 5.040000ns
signal level0 :  std_logic_vector(23 downto 0);
   -- timing of level0: 5.590000ns
signal sCount :  std_logic_vector(4 downto 0);
   -- timing of sCount: 5.040000ns
begin
   level5 <= X ;
   count4<= '1' when level5(23 downto 8) = (23 downto 8=>'0') else '0';
   level4<= level5(23 downto 0) when count4='0' else level5(7 downto 0) & (15 downto 0 => '0');

   count3<= '1' when level4(23 downto 16) = (23 downto 16=>'0') else '0';
   level3<= level4(23 downto 0) when count3='0' else level4(15 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3(23 downto 20) = (23 downto 20=>'0') else '0';
   level2<= level3(23 downto 0) when count2='0' else level3(19 downto 0) & (3 downto 0 => '0');

   count1<= '1' when level2(23 downto 22) = (23 downto 22=>'0') else '0';
   level1<= level2(23 downto 0) when count1='0' else level2(21 downto 0) & (1 downto 0 => '0');

   count0<= '1' when level1(23 downto 23) = (23 downto 23=>'0') else '0';
   level0<= level1(23 downto 0) when count0='0' else level1(22 downto 0) & (0 downto 0 => '0');

   R <= level0;
   sCount <= count4 & count3 & count2 & count1 & count0;
   Count <= sCount;
end architecture;

