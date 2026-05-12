	component ai_tensor_slice_all_ports is
		port (
			clk                    : in  std_logic                     := 'X';             -- clk
			clr0                   : in  std_logic                     := 'X';             -- clr
			clr1                   : in  std_logic                     := 'X';             -- clr
			ena                    : in  std_logic                     := 'X';             -- ena
			acc_en                 : in  std_logic                     := 'X';             -- acc_en
			zero_en                : in  std_logic                     := 'X';             -- zero_en
			load_bb_one            : in  std_logic                     := 'X';             -- load_bb_one
			load_bb_two            : in  std_logic                     := 'X';             -- load_bb_two
			load_buf_sel           : in  std_logic                     := 'X';             -- load_buf_sel
			data_in_1              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_2              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_3              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_4              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_5              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_6              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_7              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_8              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_9              : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			data_in_10             : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data_in
			shared_exponent_data   : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- shared_exponent
			cascade_data_in_col_1  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- cascade_data_in
			cascade_data_out_col_1 : out std_logic_vector(31 downto 0);                    -- cascade_data_out
			cascade_data_in_col_2  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- cascade_data_in
			cascade_data_out_col_2 : out std_logic_vector(31 downto 0);                    -- cascade_data_out
			fp32_col_1             : out std_logic_vector(31 downto 0);                    -- result
			fp32_col_2             : out std_logic_vector(31 downto 0);                    -- result
			fp32_col_1_flag        : out std_logic_vector(3 downto 0);                     -- result
			fp32_col_2_flag        : out std_logic_vector(3 downto 0)                      -- result
		);
	end component ai_tensor_slice_all_ports;

	u0 : component ai_tensor_slice_all_ports
		port map (
			clk                    => CONNECTED_TO_clk,                    --                    clk.clk
			clr0                   => CONNECTED_TO_clr0,                   --                   clr0.clr
			clr1                   => CONNECTED_TO_clr1,                   --                   clr1.clr
			ena                    => CONNECTED_TO_ena,                    --                    ena.ena
			acc_en                 => CONNECTED_TO_acc_en,                 --                 acc_en.acc_en
			zero_en                => CONNECTED_TO_zero_en,                --                zero_en.zero_en
			load_bb_one            => CONNECTED_TO_load_bb_one,            --            load_bb_one.load_bb_one
			load_bb_two            => CONNECTED_TO_load_bb_two,            --            load_bb_two.load_bb_two
			load_buf_sel           => CONNECTED_TO_load_buf_sel,           --           load_buf_sel.load_buf_sel
			data_in_1              => CONNECTED_TO_data_in_1,              --              data_in_1.data_in
			data_in_2              => CONNECTED_TO_data_in_2,              --              data_in_2.data_in
			data_in_3              => CONNECTED_TO_data_in_3,              --              data_in_3.data_in
			data_in_4              => CONNECTED_TO_data_in_4,              --              data_in_4.data_in
			data_in_5              => CONNECTED_TO_data_in_5,              --              data_in_5.data_in
			data_in_6              => CONNECTED_TO_data_in_6,              --              data_in_6.data_in
			data_in_7              => CONNECTED_TO_data_in_7,              --              data_in_7.data_in
			data_in_8              => CONNECTED_TO_data_in_8,              --              data_in_8.data_in
			data_in_9              => CONNECTED_TO_data_in_9,              --              data_in_9.data_in
			data_in_10             => CONNECTED_TO_data_in_10,             --             data_in_10.data_in
			shared_exponent_data   => CONNECTED_TO_shared_exponent_data,   --   shared_exponent_data.shared_exponent
			cascade_data_in_col_1  => CONNECTED_TO_cascade_data_in_col_1,  --  cascade_data_in_col_1.cascade_data_in
			cascade_data_out_col_1 => CONNECTED_TO_cascade_data_out_col_1, -- cascade_data_out_col_1.cascade_data_out
			cascade_data_in_col_2  => CONNECTED_TO_cascade_data_in_col_2,  --  cascade_data_in_col_2.cascade_data_in
			cascade_data_out_col_2 => CONNECTED_TO_cascade_data_out_col_2, -- cascade_data_out_col_2.cascade_data_out
			fp32_col_1             => CONNECTED_TO_fp32_col_1,             --             fp32_col_1.result
			fp32_col_2             => CONNECTED_TO_fp32_col_2,             --             fp32_col_2.result
			fp32_col_1_flag        => CONNECTED_TO_fp32_col_1_flag,        --        fp32_col_1_flag.result
			fp32_col_2_flag        => CONNECTED_TO_fp32_col_2_flag         --        fp32_col_2_flag.result
		);

