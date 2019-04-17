ESpec.configure(fn config ->
  config.before(fn _tags ->
    {:shared, []}
  end)

  config.finally(fn _shared ->
    :ok
  end)
end)
