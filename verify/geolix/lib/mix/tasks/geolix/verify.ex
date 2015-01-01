defmodule Mix.Tasks.Geolix.Verify do
  use Mix.Task

  @data_path [ __DIR__, "../../../../.." ]        |> Path.join()
  @ip_set    [ @data_path, "ip_set.txt" ]         |> Path.join() |> Path.expand()
  @results   [ @data_path, "geolix_results.txt" ] |> Path.join() |> Path.expand()

  def run(_args) do
    :ok         = Application.start(:geolix)
    result_file = @results |> File.open!([ :write, :utf8 ])

    @ip_set
      |> File.read!()
      |> String.split()
      |> check(result_file)
  end

  defp check([], _),                    do: :ok
  defp check([ ip | ips ], result_file) do
    { city_data, country_data } =
      ip
        |> Geolix.lookup()
        |> parse()

    IO.puts(result_file, "#{ ip }-#{ city_data }-#{ country_data }")

    check(ips, result_file)
  end

  defp parse(%{ city: city, country: country }) do
    { parse_city(city), parse_country(country) }
  end


  defp parse_city(%{ location: location, city: %{ names: names }}) do
    [
      location.latitude,
      location.longitude,
      names.en
    ]
      |> Enum.join("_")
  end

  defp parse_city(%{ location: location, city: city }) do
    [
      location.latitude,
      location.longitude,
      city
    ]
      |> Enum.join("_")
  end

  defp parse_city(_), do: ""


  defp parse_country(%{ country: %{ names: names }}), do: names.en

  defp parse_country(%{ country: country }), do: country

  defp parse_country(_), do: ""
end
