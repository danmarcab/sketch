defmodule GraphTest do
  use ExUnit.Case

  alias Sketch.Node
  alias Sketch.Graph

  setup do
    node_a = %Node{id: "a", data: :node_a_data}
    node_b = %Node{id: "b", data: :node_b_data}
    node_c = %Node{id: "c", data: :node_c_data}

    graph = Graph.new
    |> Graph.connect(node_a, node_b, :edge_a_b_data)
    |> Graph.connect_bi(node_b, node_c, :edge_b_c_data)
    |> Graph.connect(node_c, node_a, :edge_c_a_data)

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
    assert Graph.outbound_ids(graph, node_a) == ["b"]
    assert Graph.outbound_ids(graph, node_b) == ["c"]
    assert Graph.outbound_ids(graph, node_c) == ["a", "b"]

    assert Graph.outbound_nodes(graph, node_a) == [node_b]
    assert Graph.outbound_nodes(graph, node_b) == [node_c]
    assert Graph.outbound_nodes(graph, node_c) == [node_a, node_b]

    assert Graph.outbound(graph, node_a) == %{"b" => :edge_a_b_data}
    assert Graph.outbound(graph, node_b) == %{"c" => :edge_b_c_data}
    assert Graph.outbound(graph, node_c) == %{"a" => :edge_c_a_data, "b" => :edge_b_c_data}
  end

  test "can get inbound connected nodes", %{graph: graph, node_a: node_a, node_b: node_b, node_c: node_c} do
    assert Graph.inbound_ids(graph, node_a) == ["c"]
    assert Graph.inbound_ids(graph, node_b) == ["a", "c"]
    assert Graph.inbound_ids(graph, node_c) == ["b"]

    assert Graph.inbound_nodes(graph, node_a) == [node_c]
    assert Graph.inbound_nodes(graph, node_b) == [node_a, node_c]
    assert Graph.inbound_nodes(graph, node_c) == [node_b]

    assert Graph.inbound(graph, node_a) == %{"c" => :edge_c_a_data}
    assert Graph.inbound(graph, node_b) == %{"a" => :edge_a_b_data, "c" => :edge_b_c_data}
    assert Graph.inbound(graph, node_c) == %{"b" => :edge_b_c_data}
  end
end
