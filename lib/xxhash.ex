defmodule XXHash do

  use Bitwise

  # Hashing constants.
  @prime32_1 2654435761
  @prime32_2 2246822519
  @prime32_3 3266489917
  @prime32_4 668265263
  @prime32_5 374761393

  @prime64_1 11400714785074694791
  @prime64_2 14029467366897019727
  @prime64_3 1609587929392839161
  @prime64_4 9650029242287828579
  @prime64_5 2870177450012600261

  # Make sure integers are 32 or 64 bit long.
  defmacrop mask32(x), do: quote do: unquote(x) &&& 0xFFFFFFFF
  defmacrop mask64(x), do: quote do: unquote(x) &&& 0xFFFFFFFFFFFFFFFF

  # Hash 32 bit integers.
  @spec xxh32(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh32(<<>>, length, seed), do: 0
  def xxh32(input, length, seed) do
    if length >= 16 do
      h32 = 0 # Needs implementation, loop until 16 left.
    else
      h32 = seed + @prime32_5;
    end

    # possibly modify input here.
    h32 + length |> do_xxh32(input)

    #while (p+4<=bEnd)
    #{
    #  h32 += XXH_get32bits(p) * PRIME32_3;
    #  h32  = XXH_rotl32(h32, 17) * PRIME32_4 ;
    #  p+=4;
    #}

    #while (p<bEnd)
    #{
    #  h32 += (*p) * PRIME32_5;
    #  h32 = XXH_rotl32(h32, 11) * PRIME32_1 ;
    #  p++;
    #}

    #h32 ^= h32 >> 15;
    #h32 *= PRIME32_2;
    #h32 ^= h32 >> 13;
    #h32 *= PRIME32_3;
    #h32 ^= h32 >> 16;

    h32
  end

  defp do_xxh32(h, <<p::8>>) do
    ((h + p * @prime32_5) |> rotl32(11)) * @prime32_1
  end
  defp do_xxh32(h, <<a::8, b::8, c::8, d::8>>) do
    h |> do_xxh32(a) |> do_xxh32(b) |> do_xxh32(c) |> do_xxh32(d)
  end
  defp do_xxh32(h, <<p::32, rest::binary>>) do
    (((h + read32(p) * @prime32_3) |> rotl32(17)) * @prime32_4) |> do_xxh32(rest)
  end

  # Hash 64 bit integers.
  @spec xxh64(binary | term, non_neg_integer, non_neg_integer) :: non_neg_integer
  def xxh64(<<>>, length, seed), do: 0
  def xxh64(input, length, seed) do
    0
  end

  # Detect endianess.
  #@spec endianness() :: atom
  #defp endianness() when <<1::32-little>> == <<1::32-native>>, do: :endianness_little
  #defp endianness(), do: :endianness_big

  # Swap bytes of 32 bit integer.
  #@spec byteswap32(integer) :: integer
  defp byteswap32(value) do <<y::32-big>> = <<value::32-little>>; y end

  # Swap bytes of 64 bit integer.
  #@spec byteswap64(integer) :: integer
  defp byteswap64(value) do <<y::64-big>> = <<value::64-little>>; y end

  # Perform rotation left for 32 bit integer.
  #@spec rotl32(integer, non_neg_integer) :: integer
  defp rotl32(value, shift), do: ((value <<< shift) ||| (value >>> (32 - shift)))

  # Perform rotation left for 64 bit integer.
  #@spec rotl64(integer, non_neg_integer) :: integer
  defp rotl64(value, shift), do: ((value <<< shift) ||| (value >>> (64 - shift)))

  # Read 32 bit integer.
  defp read32(<<value::32>>) when <<1::32-little>> == <<1::32-native>>, do: value
  defp read32(<<value::32>>), do: byteswap32(value)

  # Read 64 bit integer.
  defp read64(<<value::64>>) when <<1::64-little>> == <<1::64-native>>, do: value
  defp read64(<<value::64>>), do: byteswap64(value)
end
