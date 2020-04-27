defmodule WeChat.Component do
  @moduledoc false

  require Logger

  defmacro __using__(opts \\ []) do
    opts =
      opts
      |> Macro.prewalk(&Macro.expand(&1, __CALLER__))
      |> initialize_opts()

    quote do
      @opts unquote(opts)

      def request(method, options) do
        options = WeChat.Utils.merge_keyword(options, @opts)
        WeChat.request(method, options)
      end
    end
  end

  defp initialize_opts(opts) do
    Keyword.merge(opts,
      adapter_storage: map_adapter_storage(opts[:adapter_storage]),
      appid: opts[:appid],
      authorizer_appid: opts[:authorizer_appid]
    )
  end

  defp map_adapter_storage({:default, hub_base_url}) when is_bitstring(hub_base_url) do
    {WeChat.Storage.Adapter.DefaultComponentClient, [hub_base_url: hub_base_url]}
  end
  defp map_adapter_storage(adapter_storage) when is_atom(adapter_storage) do
    WeChat.ensure_implements(
      adapter_storage,
      [
        WeChat.Storage.ComponentClient,
        WeChat.Storage.ComponentHub
      ]
    )
    {adapter_storage, []}
  end
  defp map_adapter_storage({adapter_storage, args}) when is_atom(adapter_storage) and is_list(args) do
    WeChat.ensure_implements(
      adapter_storage,
      [
        WeChat.Storage.ComponentClient,
        WeChat.Storage.ComponentHub
      ]
    )
    {adapter_storage, args}
  end
  defp map_adapter_storage(invalid) do
    raise %WeChat.Error{
      reason: :invalid_adapter_storage_impl,
      message: "Using unexpected #{inspect(invalid)} adapter storage, please use it as `WeChat.Storage.ComponentClient` or `WeChat.Storage.ComponentHub`"
    }
  end

end
