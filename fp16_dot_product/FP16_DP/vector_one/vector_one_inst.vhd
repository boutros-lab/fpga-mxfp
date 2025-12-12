	component vector_one is
		port (
			fp32_chainin    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- fp32_chainin
			fp16_mult_top_a : in  std_logic_vector(15 downto 0) := (others => 'X'); -- fp16_mult_top_a
			fp16_mult_top_b : in  std_logic_vector(15 downto 0) := (others => 'X'); -- fp16_mult_top_b
			fp16_mult_bot_a : in  std_logic_vector(15 downto 0) := (others => 'X'); -- fp16_mult_bot_a
			fp16_mult_bot_b : in  std_logic_vector(15 downto 0) := (others => 'X'); -- fp16_mult_bot_b
			fp32_adder_a    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- fp32_adder_a
			clr0            : in  std_logic                     := 'X';             -- reset
			clr1            : in  std_logic                     := 'X';             -- reset
			clk             : in  std_logic                     := 'X';             -- clk
			ena             : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- ena
			fp32_result     : out std_logic_vector(31 downto 0);                    -- fp32_result
			fp32_chainout   : out std_logic_vector(31 downto 0)                     -- fp32_chainout
		);
	end component vector_one;

	u0 : component vector_one
		port map (
			fp32_chainin    => CONNECTED_TO_fp32_chainin,    --    fp32_chainin.fp32_chainin
			fp16_mult_top_a => CONNECTED_TO_fp16_mult_top_a, -- fp16_mult_top_a.fp16_mult_top_a
			fp16_mult_top_b => CONNECTED_TO_fp16_mult_top_b, -- fp16_mult_top_b.fp16_mult_top_b
			fp16_mult_bot_a => CONNECTED_TO_fp16_mult_bot_a, -- fp16_mult_bot_a.fp16_mult_bot_a
			fp16_mult_bot_b => CONNECTED_TO_fp16_mult_bot_b, -- fp16_mult_bot_b.fp16_mult_bot_b
			fp32_adder_a    => CONNECTED_TO_fp32_adder_a,    --    fp32_adder_a.fp32_adder_a
			clr0            => CONNECTED_TO_clr0,            --            clr0.reset
			clr1            => CONNECTED_TO_clr1,            --            clr1.reset
			clk             => CONNECTED_TO_clk,             --             clk.clk
			ena             => CONNECTED_TO_ena,             --             ena.ena
			fp32_result     => CONNECTED_TO_fp32_result,     --     fp32_result.fp32_result
			fp32_chainout   => CONNECTED_TO_fp32_chainout    --   fp32_chainout.fp32_chainout
		);

