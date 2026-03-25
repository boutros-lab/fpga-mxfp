--------------------------------------------------------------------------------
--                               fp8_67_shifter
--                     (LeftShifter9_by_max_60_comb_uid2)
-- VHDL generated for DummyFPGA @ 0MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- combinatorial
-- Clock period (ns): inf
-- Target frequency (MHz): 0
-- Input signals: X S padBit
-- Output signals: R
--  approx. input signal timings: X: 0.000000nsS: 0.000000nspadBit: 0.000000ns
--  approx. output signal timings: R: 3.311538ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity fp8_67_shifter is
    port (X : in  std_logic_vector(8 downto 0);
          S : in  std_logic_vector(5 downto 0);
          padBit : in  std_logic;
          R : out  std_logic_vector(66 downto 0)   );
end entity;

architecture arch of fp8_67_shifter is
signal ps :  std_logic_vector(5 downto 0);
   -- timing of ps: 0.000000ns
signal level0 :  std_logic_vector(8 downto 0);
   -- timing of level0: 0.000000ns
signal level1 :  std_logic_vector(9 downto 0);
   -- timing of level1: 0.000000ns
signal level2 :  std_logic_vector(11 downto 0);
   -- timing of level2: 0.734615ns
signal level3 :  std_logic_vector(15 downto 0);
   -- timing of level3: 0.734615ns
signal level4 :  std_logic_vector(23 downto 0);
   -- timing of level4: 1.653846ns
signal level5 :  std_logic_vector(39 downto 0);
   -- timing of level5: 1.653846ns
signal level6 :  std_logic_vector(71 downto 0);
   -- timing of level6: 3.311538ns
begin
   ps<= S;
   level0<= X;
   level1<= level0 & (0 downto 0 => '0') when ps(0)= '1' else     (0 downto 0 => padBit) & level0;
   level2<= level1 & (1 downto 0 => '0') when ps(1)= '1' else     (1 downto 0 => padBit) & level1;
   level3<= level2 & (3 downto 0 => '0') when ps(2)= '1' else     (3 downto 0 => padBit) & level2;
   level4<= level3 & (7 downto 0 => '0') when ps(3)= '1' else     (7 downto 0 => padBit) & level3;
   level5<= level4 & (15 downto 0 => '0') when ps(4)= '1' else     (15 downto 0 => padBit) & level4;
   level6<= level5 & (31 downto 0 => '0') when ps(5)= '1' else     (31 downto 0 => padBit) & level5;
   R <= level6(66 downto 0);
end architecture;

