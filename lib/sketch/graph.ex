defmodule Sketch.Graph do
  @moduledoc """
  Provides functions to model graph-like structures.
  """

  defstruct nodes: %{}, in_edges: %{}, out_edges: %{}

  @doc """
  Creates an empty graph

  ## Examples

      iex> Sketch.Graph.new
      ...> |> Sketch.Graph.nodes
      []
  """
  def new, do: %__MODULE__{}

  @doc """
  Adds/Updates a node in the graph

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.put_node("a")
      iex>  g |> Sketch.Graph.nodes
      ["a"]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.put_node("a", :data)
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :data}
      iex> g
      ...> |> Sketch.Graph.put_node("a", :new_data)
      ...> |> Sketch.Graph.nodes(data: true)
      %{"a" => :new_data}
  """
  def put_node(%__MODULE__{nodes: nodes} = graph, node_id, node_data \\ nil) do
    %{graph | nodes: Map.put(nodes, node_id, node_data)}
  end

  @doc """
  Adds/Updates a list of nodes in the graph

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.put_nodes(["a", "b", "c"])
      iex>  g |> Sketch.Graph.nodes
      ["a", "b", "c"]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.put_nodes([{"a", :a_data}, {"b", :b_data}])
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :a_data, "b" => :b_data}
      iex> g
      ...> |> Sketch.Graph.put_nodes([{"a", :a_new_data}, {"b", :b_new_data}])
      ...> |> Sketch.Graph.nodes(data: true)
      %{"a" => :a_new_data, "b" => :b_new_data}
  """
  def put_nodes(%__MODULE__{} = graph, nodes) do
    nodes
    |> Enum.reduce(graph, fn
      {node_id, node_data}, g -> put_node(g, node_id, node_data)
      node_id, g              -> put_node(g, node_id)
    end)
  end

  @doc """
  Adds a node in the graph only if it doesn't exist yet

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_node("a")
      iex>  g |> Sketch.Graph.nodes
      ["a"]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_node("a", :data)
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :data}
      iex> g
      ...> |> Sketch.Graph.add_node("a", :new_data)
      ...> |> Sketch.Graph.nodes(data: true)
      %{"a" => :data}
  """
  def add_node(%__MODULE__{} = graph, node_id, node_data \\ nil) do
    if has_node?(graph, node_id), do: graph, else: put_node(graph, node_id, node_data)
  end

  @doc """
  Adds a list of nodes in the graph only if they don't exist yet

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_nodes(["a", "b", "c"])
      iex>  g |> Sketch.Graph.nodes
      ["a", "b", "c"]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_nodes([{"a", :a_data}, {"b", :b_data}])
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :a_data, "b" => :b_data}
      iex> g
      ...> |> Sketch.Graph.add_nodes([{"a", :a_new_data}, {"b", :b_new_data}])
      ...> |> Sketch.Graph.nodes(data: true)
      %{"a" => :a_data, "b" => :b_data}
  """
  def add_nodes(%__MODULE__{} = graph, nodes) do
    nodes
    |> Enum.reduce(graph, fn
      {node_id, node_data}, g -> add_node(g, node_id, node_data)
      node_id, g              -> add_node(g, node_id)
    end)
  end

  @doc """
  Checks if a node is part of the graph

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_node("a")
      iex>  g |> Sketch.Graph.has_node?("a")
      true
      iex>  g |> Sketch.Graph.has_node?("b")
      false
  """
  def has_node?(%__MODULE__{nodes: nodes}, node_id) do
    nodes
    |> Map.has_key?(node_id)
  end

  @doc """
  Get list of nodes of the graph

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_node("a")
      iex>  g |> Sketch.Graph.nodes
      ["a"]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_node("a", :data)
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :data}
  """
  def nodes(%__MODULE__{nodes: nodes}) do
    nodes |> Map.keys
  end

  def nodes(%__MODULE__{nodes: nodes}, data: true) do
    nodes
  end

  @doc """
  Add an edge to the graph. If any of the nodes are not in the graph,
  it adds them

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_edge("a", "b")
      iex>  g |> Sketch.Graph.nodes
      ["a", "b"]
      iex>  g |> Sketch.Graph.edges
      [{"a", "b"}]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_edge({"a", :a_data}, {"b", :b_data}, :edge_data)
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :a_data, "b" => :b_data}
      iex>  g |> Sketch.Graph.edges(data: true)
      %{{"a", "b"} => :edge_data}
  """
  def add_edge(%__MODULE__{} = graph, node_a, node_b, edge_data \\ nil) do
    {id_a, data_a} = extract(node_a)
    {id_b, data_b} = extract(node_b)

    graph
    |> add_node(id_a, data_a)
    |> add_node(id_b, data_b)
    |> add_out_edge(id_a, id_b, edge_data)
    |> add_in_edge(id_b, id_a, edge_data)
  end

  @doc """
  Add a list of edges to the graph. If any of the nodes are not in the graph,
  it adds them

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_edges([{"a", "b"}, {"b", "c"}])
      iex>  g |> Sketch.Graph.nodes
      ["a", "b", "c"]
      iex>  g |> Sketch.Graph.edges
      [{"a", "b"}, {"b", "c"}]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_edges([
      ...>   {{"a", :a_data}, {"b", :b_data}, :a_b_data},
      ...>   {"b", {"c", :c_data}, :b_c_data}
      ...> ])
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :a_data, "b" => :b_data, "c" => :c_data}
      iex>  g |> Sketch.Graph.edges(data: true)
      %{{"a", "b"} => :a_b_data, {"b", "c"} => :b_c_data}
  """
  def add_edges(%__MODULE__{} = graph, edges) do
    edges
    |> Enum.reduce(graph, fn
      ({node_a, node_b}, g) -> add_edge(g, node_a, node_b)
      ({node_a, node_b, data}, g) -> add_edge(g, node_a, node_b, data)
    end)
  end

  @doc """
  Test if two nodes are connected.

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_edges([{"a", "b"}, {"b", "c"}])
      iex>  g |> Sketch.Graph.are_connected?("a", "b")
      true
      iex>  g |> Sketch.Graph.are_connected?("b", "a")
      false
      iex>  g |> Sketch.Graph.are_connected?("a", "c")
      false
  """
  def are_connected?(%__MODULE__{out_edges: out_edges}, id_a, id_b) do
    out_edges
    |> Map.get(id_a, %{})
    |> Map.has_key?(id_b)
  end

  @doc """
  Get list of edges of the graph.

  ## Examples

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_edge("a", "b")
      iex>  g |> Sketch.Graph.nodes
      ["a", "b"]
      iex>  g |> Sketch.Graph.edges
      [{"a", "b"}]

      iex> g = Sketch.Graph.new
      ...> |> Sketch.Graph.add_edge({"a", :a_data}, {"b", :b_data}, :edge_data)
      iex>  g |> Sketch.Graph.nodes(data: true)
      %{"a" => :a_data, "b" => :b_data}
      iex>  g |> Sketch.Graph.edges(data: true)
      %{{"a", "b"} => :edge_data}
  """
  def edges(%__MODULE__{out_edges: edges} = graph, data: true) do
    edges
    |> Enum.reduce([], fn {from_id, adjacent}, list ->
      list ++ (for {to_id, data} <- adjacent, do: {{from_id, to_id}, data})
    end)
    |> Enum.into(%{})
  end

  def edges(%__MODULE__{out_edges: edges} = graph) do
    edges(graph, data: true)
    |> Map.keys
  end

  defp add_out_edge(%__MODULE__{out_edges: out_edges} = graph, id_a, id_b, edge_data) do
    a_out_edges = Map.get(out_edges, id_a, %{}) |> Map.put(id_b, edge_data)
    %{graph | out_edges: Map.put(out_edges, id_a, a_out_edges)}
  end

  defp add_in_edge(%__MODULE__{in_edges: in_edges} = graph, id_a, id_b, edge_data) do
    a_in_edges = Map.get(in_edges, id_a, %{}) |> Map.put(id_b, edge_data)
    %{graph | in_edges: Map.put(in_edges, id_a, a_in_edges)}
  end

  defp extract({id, data}), do: {id, data}
  defp extract(id), do: {id, nil}
end
