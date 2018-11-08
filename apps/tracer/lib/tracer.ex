defmodule Tracer do
  require Logger
  use GenServer

  @patterns [
    {Tracer, :i_trace, 0},
    {Tracee, :im_traced, 1}
  ]

  def i_trace() do
    Tracee.im_traced(:ok)
  end

  def start_link(reporter) do
    {:ok, pid} = GenServer.start_link(__MODULE__, reporter, name: __MODULE__)
    start_trace(pid)
    {:ok, pid}
  end

  def init(reporter) do
    {:ok, %{reporter: reporter}}
  end

  def handle_info({:trace_ts, _pid, :call, mfa, _timestamp}, state) do
    Logger.warn(inspect(mfa))
    send(state.reporter, {:report, %{name: inspect(mfa)}})
    {:noreply, state}
  end

  def handle_info({:set_reporter, pid}, state) do
    {:noreply, %{state | reporter: pid}}
  end

  def handle_info(message, state) do
    IO.inspect message
    {:noreply, state}
  end

  def start_trace(pid) do
    default_match_spec = [{:_, [], [{:return_trace}]}]
    :erlang.trace(:all, true, [:call, :monotonic_timestamp, tracer: pid])

    for pattern <- @patterns do
      :erlang.trace_pattern(pattern, default_match_spec, [:local])
    end
  end
end
