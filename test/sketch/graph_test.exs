defmodule GraphTest do
  use ExUnit.Case

  alias Sketch.Node
  alias Sketch.Graph

  setup do
    node_a = %Node{id: "a", data: :node_a_data}
    node_b = %Node{id: "b", data: :node_b_data}
    node_c = %Node{id: "c", data: :node_c_data}

    graph = Graph.new
    |> Graph.connect(node_a, node_b)
    |> Graph.connect_bi(node_b, node_c)
    |> Graph.connect(node_c, node_a)

    {:ok, graph: graph, node_a: node_a, node_b: node_b, node_c: node_c}
  end

  test "add nodes to graph", %{graph: graph, node_a: node_a, node_b: node_b, node_c: node_c} do
    assert Graph.has_node?(graph, node_a)
    assert Graph.has_node?(graph, node_b)
    assert Graph.has_node?(graph, node_c)
  end

  test "connect nodes in graph", %{graph: graph, node_a: node_a, node_b: node_b, node_c: node_c} do
    assert Graph.are_connected?(graph, node_a, node_b)
    refute Graph.are_connected?(graph, node_b, node_a)

    assert Graph.are_connected?(graph, node_b, node_c)
    assert Graph.are_connected?(graph, node_c, node_b)

    assert Graph.are_connected?(graph, node_c, node_a)
    refute Graph.are_connected?(graph, node_a, node_c)
  end

  test "can get outbound connected nodes", %{graph: graph, node_a: node_a, node_b: node_b, node_c: node_c} do
    assert Graph.outbound(graph, node_a) == [node_b]
    assert Graph.outbound(graph, node_b) == [node_c]
    assert Graph.outbound(graph, node_c) == [node_a, node_b]
  end

  test "can get inbound connected nodes", %{graph: graph, node_a: node_a, node_b: node_b, node_c: node_c} do
    assert Graph.inbound(graph, node_a) == [node_c]
    assert Graph.inbound(graph, node_b) == [node_a, node_c]
    assert Graph.inbound(graph, node_c) == [node_b]
  end
end
