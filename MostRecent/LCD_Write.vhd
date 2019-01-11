library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_Write is
	port(
		Clk				:	in  std_logic;
		Reset_n				: 	in std_logic;
		
		--Configuration registers
		Write_Ack			:	out std_logic;	
		Cmd_Address			:	in std_logic_vector(15 downto 0);
		Cmd_Data			:	in std_logic_vector(15 downto 0);
		New_Cmd				:	in std_logic; --new_command
		
		--Signals connected to FIFO
		
		FIFO_Empty			:	in std_logic;
		Rd_FIFO				:	in std_logic_vector(31 downto 0);
		FIFO_Rd_Sig			:	out std_logic;		
		
		--LCD Signals 
		RGB_out				: 	out std_logic_vector(15 downto 0);
		CSX				:	out std_logic;
		DCX				:	out std_logic;
		WRX				:	out std_logic;
		RDX				:	out std_logic	--may or may not need, only for reading registers
	);	
end entity LCD_Write;

architecture behavioural of LCD_Write is

-- State definition

type state is (Idle, Address_Setup, Write_Activate, Write_Pulse_L, Write_Pulse_H_1, Write_Pulse_H_2, Write_Activate_Data, 
		Write_Pulse_L_Data, Write_Pulse_H_1_Data, Write_Pulse_H_2_Data, Write_Activate_FIFO_1, Write_Pulse_L_FIFO_1, Write_Pulse_H_1_FIFO_1, Write_Pulse_H_2_FIFO_1, Write_Activate_Data_FIFO_1, 
		Write_Pulse_L_Data_FIFO_1, Write_Pulse_H_1_Data_FIFO_1, Write_Pulse_H_2_Data_FIFO_1, Write_Activate_FIFO_2, Write_Pulse_L_FIFO_2, Write_Pulse_H_1_FIFO_2, Write_Pulse_H_2_FIFO_2, Write_Activate_Data_FIFO_2, 
		Write_Pulse_L_Data_FIFO_2, Write_Pulse_H_1_Data_FIFO_2, Write_Pulse_H_2_Data_FIFO_2, Address_Setup_FIFO); 
signal CurrentState,NextState: state;

-- Auxiliary constants and signals 

Signal TmpAddress	: std_logic_vector (15 downto 0);
Signal TmpData		: std_logic_vector (15 downto 0);
--To take into account the 32 bits from the fifo is two pieces of 16 bit data
Signal FirstFIFO	: std_logic_vector (15 downto 0);
Signal SecondFIFO	: std_logic_vector (15 downto 0);

Begin
	NS_process: Process(Clk, Reset_n)
	begin 
		if Reset_n = '0' then
			CurrentState <= Idle;
		elsif rising_edge(clk) then
			CurrentState <= NextState;
	  	end if;
	end process;

	Write_process: Process (CurrentState, New_cmd, Clk)

	Begin

	NextState <= CurrentState;
	RGB_out <= (others => '0');
	WRX <= '1';
	RDX <= '1';
	CSX <= '1';
	DCX <= '1';
	Write_ack <= '0';
	FIFO_Rd_Sig <= '0';

	case CurrentState is
		when Idle =>			

			if New_Cmd= '1' then
				TmpAddress <= Cmd_Address;
				TmpData <= Cmd_Data;
				NextState <= Address_Setup;
				Write_Ack <= '1';
			elsif FIFO_Empty = '0' then
				FIFO_Rd_Sig <= '1';
				TmpAddress <= x"002C";
				FirstFIFO <= Rd_FIFO(31 downto 16);
				SecondFIFO <= Rd_FIFO(15 downto 0);
				NextState <= Address_Setup_FIFO;
			end if;

		when Address_Setup =>
			NextState <= Write_Activate;
			CSX <= '0';
			DCX <= '0';
	
		--begin to write the address from registers
		when Write_Activate =>
			WRX <= '0';
			CSX <= '0';
			DCX <= '0'; --DCX is zero for the command and 1 for data
			NextState <= Write_Pulse_L;

		when Write_Pulse_L =>
			RGB_out <= TmpAddress;
			WRX <= '0';
			CSX <= '0';
			DCX <= '0';
			NextState <= Write_Pulse_H_1;
		
		when Write_Pulse_H_1 =>
			WRX <= '1';
			DCX <= '0';
			CSX <= '0';
			RGB_out <= TmpAddress;
			NextState <= Write_Pulse_H_2;

		when Write_Pulse_H_2 =>
			WRX <= '1';
			DCX <= '0';
			CSX <= '0';
			NextState <= Write_Activate_Data;

		--repeat the same states but for writing the data
		when Write_Activate_Data =>
			WRX <= '0';
			DCX <= '1';
			CSX <= '0';
			NextState <= Write_Pulse_L_Data;

		when Write_Pulse_L_Data =>
			RGB_out <= TmpData;
			WRX <= '0';
			DCX <= '1';
			CSX <= '0';
			NextState <= Write_Pulse_H_1_Data;
		
		when Write_Pulse_H_1_Data =>
			WRX <= '1';
			DCX <= '1';
			CSX <= '0';
			RGB_out <= TmpData;
			NextState <= Write_Pulse_H_2_Data;

		when Write_Pulse_H_2_Data =>
			WRX <= '1';
			DCX <= '1';
			CSX <= '0';
			NextState <= Idle;

		--For the FIFO, write both of the data recieved from the fifo, therefore repeat the above twice
		when Address_Setup_FIFO =>
			NextState <= Write_Activate_FIFO_1;
			CSX <= '0';
			DCX <= '0';

		when Write_Activate_FIFO_1 =>
			WRX <= '0';
			CSX <= '0';
			DCX <= '0'; --DCX is zero for the command and 1 for data
			NextState <= Write_Pulse_L_FIFO_1;

		when Write_Pulse_L_FIFO_1 =>
			RGB_out <= TmpAddress;
			WRX <= '0';
			CSX <= '0';
			DCX <= '0';
			NextState <= Write_Pulse_H_1_FIFO_1;
		
		when Write_Pulse_H_1_FIFO_1 =>
			WRX <= '1';
			DCX <= '0';
			CSX <= '0';
			RGB_out <= TmpAddress;
			NextState <= Write_Pulse_H_2_FIFO_1;

		when Write_Pulse_H_2_FIFO_1 =>
			WRX <= '1';
			DCX <= '0';
			CSX <= '0';
			NextState <= Write_Activate_Data_FIFO_1;

		--repeat the same states but for writing the data
		when Write_Activate_Data_FIFO_1 =>
			WRX <= '0';
			DCX <= '1';
			CSX <= '0';
			NextState <= Write_Pulse_L_Data_FIFO_1;

		when Write_Pulse_L_Data_FIFO_1 =>
			RGB_out <= FirstFIFO;
			WRX <= '0';
			DCX <= '1';
			CSX <= '0';
			NextState <= Write_Pulse_H_1_Data_FIFO_1;
		
		when Write_Pulse_H_1_Data_FIFO_1 =>
			WRX <= '1';
			DCX <= '1';
			CSX <= '0';
			RGB_out <= FirstFIFO;
			NextState <= Write_Pulse_H_2_Data_FIFO_1;

		when Write_Pulse_H_2_Data_FIFO_1 =>
			WRX <= '1';
			DCX <= '1';
			CSX <= '0';
			NextState <= Write_Activate_FIFO_2;

		--Second pixel 
		when Write_Activate_FIFO_2 =>
			WRX <= '0';
			CSX <= '0';
			DCX <= '0'; --DCX is zero for the command and 1 for data
			NextState <= Write_Pulse_L_FIFO_2;

		when Write_Pulse_L_FIFO_2 =>
			RGB_out <= TmpAddress;
			WRX <= '0';
			CSX <= '0';
			DCX <= '0';
			NextState <= Write_Pulse_H_1_FIFO_2;
		
		when Write_Pulse_H_1_FIFO_2 =>
			WRX <= '1';
			DCX <= '0';
			CSX <= '0';
			RGB_out <= TmpAddress;
			NextState <= Write_Pulse_H_2_FIFO_2;

		when Write_Pulse_H_2_FIFO_2 =>
			WRX <= '1';
			DCX <= '0';
			CSX <= '0';
			NextState <= Write_Activate_Data_FIFO_2;

		--repeat the same states but for writing the data
		when Write_Activate_Data_FIFO_2 =>
			WRX <= '0';
			DCX <= '1';
			CSX <= '0';
			NextState <= Write_Pulse_L_Data_FIFO_2;

		when Write_Pulse_L_Data_FIFO_2 =>
			RGB_out <= SecondFIFO;
			WRX <= '0';
			DCX <= '1';
			CSX <= '0';
			NextState <= Write_Pulse_H_1_Data_FIFO_2;
		
		when Write_Pulse_H_1_Data_FIFO_2 =>
			WRX <= '1';
			DCX <= '1';
			CSX <= '0';
			RGB_out <= SecondFIFO;
			NextState <= Write_Pulse_H_2_Data_FIFO_2;

		when Write_Pulse_H_2_Data_FIFO_2 =>
			WRX <= '1';
			DCX <= '1';
			CSX <= '0';
			NextState <= Idle;

		when others =>
			NextState <= Idle;
			
	end case;	

end process Write_process;
	
end ;
