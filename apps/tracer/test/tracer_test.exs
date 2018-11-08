defmodule Tracer.TracerTest do
  use ExUnit.Case

  test "tracing" do
    Tracer.start_link(self())
    Tracer.i_trace()
    assert_span("{Tracer, :i_trace, []}")
    assert_span("{Tracee, :im_traced, [:ok]}")
  end

  defp assert_span(name) do
    assert_receive({:report, %{name: ^name} = span}, 2_000)
    span
  end
end
