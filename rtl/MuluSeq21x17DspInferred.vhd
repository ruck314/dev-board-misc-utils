-------------------------------------------------------------------------------
-- File       : MuluSeq21x17DspInferred.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: MuluSeq21x17Dsp (21x17 bit unsigned multiplier) implementation
--              using inferred DSP48 slices.
-------------------------------------------------------------------------------
-- This file is part of 'Development Board Misc. Utilities Library'
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'Development Board Misc. Utilities Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture DspInferred of MuluSeq21x17Dsp is
   type RegType is record
      a  : signed(21 downto 0);
      b  : signed(17 downto 0);
      m  : signed(39 downto 0);
      c  : signed(47 downto 0);
      p  : signed(47 downto 0);
      s17: std_logic;
      z  : std_logic;
   end record RegType;

   constant REG_INIT_C : RegType := (
      a   => (others => '0'),
      b   => (others => '0'),
      m   => (others => '0'),
      c   => (others => '0'),
      p   => (others => '0'),
      s17 => '0',
      z   => '0'
   );

   signal r : RegType := REG_INIT_C;

   signal rin : RegType;

begin

   P_CMB : process ( a, b, c, z, cec, s17, r ) is
      variable v: RegType;
   begin
      v     := r;
      v.a   := signed( resize(a, v.a'length) );
      v.b   := signed( resize(b, v.b'length) );
      v.m   := r.a*r.b;
      v.s17 := s17;
      v.z   := z;

      if ( cec = '1' ) then
        v.c := signed( resize(c, v.c'length) );
      end if;

      if ( r.z = '1' ) then
         v.p := r.p + r.c;
      else
         if ( r.s17 = '1' ) then
            v.p := shift_right(r.p, 17) + r.m;
         else
            v.p := r.p + r.m;
         end if;
      end if;

      rin <= v;
   end process P_CMB;

   P_SEQ : process ( clk ) is
      variable v : RegType;
   begin
      if ( rising_edge( clk ) ) then
         v := rin;
         if ( rst = '1' ) then
            v   := REG_INIT_C;
         elsif ( rstpm = '1' ) then
            v.m := (others => '0');
            v.p := (others => '0');
         end if;
         r <= v after TPD_G;
      end if;
   end process P_SEQ;

   p <= unsigned( resize(r.p, p'length) );

end architecture DspInferred;
