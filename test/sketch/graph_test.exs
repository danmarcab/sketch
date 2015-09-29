defmodule GraphTest do
  use ExUnit.Case

  doctest Sketch.Graph
  alias Sketch.Graph

  def simple_graph do
    Graph.new
    |> Graph.add_edge("a", "b")
    |> Graph.add_edges([{"b", "c"},{"c", "b"},{"c", "a"}])
  end

  def graph do
    Graph.new
    |> Graph.add_edge({"a", :data_a}, {"b", :data_b}, :data_a_b)
    |> Graph.add_edge("b", {"c", :data_c}, :data_b_c)
    |> Graph.add_edges([{"c", "b", :data_c_b}, {"c", "a", :data_c_a}])
  end

  setup do
    {:ok, simple_graph: simple_graph, graph: graph}
  end

  test "get nodes of graph", %{graph: graph, simple_graph: simple_graph} do
    assert Graph.nodes(simple_graph) == ["a", "b", "c"]
    assert Graph.nodes(simple_graph, data: true) == %{"a" => nil, "b" => nil, "c" => nil}

    assert Graph.nodes(graph) == ["a", "b", "c"]
    assert Graph.nodes(graph, data: true) == %{"a" => :data_a, "b" => :data_b, "c" => :data_c}
  end

  test "get edges of graph", %{graph: graph, simple_graph: simple_graph} do
    assert Enum.sort(Graph.edges(simple_graph)) == Enum.sort([{"a", "b"}, {"b", "c"}, {"c", "b"}, {"c", "a"}])
    assert Graph.edges(simple_graph, data: true) == %{
      {"a", "b"} => nil,
      {"b", "c"} => nil,
      {"c", "b"} => nil,
      {"c", "a"} => nil
    }

    assert Enum.sort(Graph.edges(graph)) == Enum.sort([{"a", "b"}, {"b", "c"}, {"c", "b"}, {"c", "a"}])
    assert Graph.edges(graph, data: true) == %{
      {"a", "b"} => :data_a_b,
      {"b", "c"} => :data_b_c,
      {"c", "b"} => :data_c_b,
      {"c", "a"} => :data_c_a
    }
  end
end
