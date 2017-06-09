defmodule Mix.Tasks.Geolix.Verify do
  @moduledoc """
  Verifies Geolix results.
  """

  use Mix.Task

  @shortdoc "Verifies parser results"

  @data_path [ __DIR__, "../../../../.." ]        |> Path.join()
  @ip_set    [ @data_path, "ip_set.txt" ]         |> Path.join() |> Path.expand()
  @results   [ @data_path, "geolix_results.txt" ] |> Path.join() |> Path.expand()

  def run(_args) do
    { :ok, _ }  = Application.ensure_all_started(:geolix)
    result_file = @results |> File.open!([ :write, :utf8 ])

    @ip_set
      |> File.read!()
      |> String.split()
      |> check(result_file)
  end

  defp check([], _),                    do: :ok
  defp check([ ip | ips ], result_file) do
    { asn_data, city_data, country_data } =
      ip
        |> Geolix.lookup()
        |> parse()

    IO.puts(result_file, "#{ ip }-#{ asn_data }-#{ city_data }-#{ country_data }")

    check(ips, result_file)
  end

  defp parse(%{ asn: asn, city: city, country: country }) do
    { parse_asn(asn), parse_city(city), parse_country(country) }
  end


  defp parse_asn(%{ autonomous_system_number: num }), do: num
  defp parse_asn(_), do: ""

  defp parse_city(%{ location: location, city: city }) do
    [
      city_latitude(location),
      city_longitude(location),
      city_name(city)
    ]
      |> Enum.join("_")
  end

  defp parse_city(_), do: ""


  defp city_latitude(%{ latitude: latitude }), do: latitude
  defp city_latitude(nil),                     do: "None"

  defp city_longitude(%{ longitude: longitude }), do: longitude
  defp city_longitude(nil),                       do: "None"

  defp city_name(%{ names: names }), do: names.en
  defp city_name(%{}),               do: ""
  defp city_name(city),              do: city


  defp parse_country(%{ country: %{ names: names }}), do: names.en
  defp parse_country(%{ country: %{} }),              do: ""
  defp parse_country(%{ country: country }),          do: country

  defp parse_country(_), do: ""
end
