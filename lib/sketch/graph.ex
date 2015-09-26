defmodule Sketch.Graph do
  defstruct nodes: %{}, inbound: %{}, outbound: %{}

  alias Sketch.Node

  def new, do: %__MODULE__{}

  def put_node(%__MODULE__{nodes: nodes} = graph, %Node{id: id} = node) do
    %{graph | nodes: Map.put(nodes, id, node)}
  end

  def add_node(%__MODULE__{} = graph, %Node{} = node) do
    if has_node?(graph, node), do: graph, else: put_node(graph, node)
  end

  def has_node?(%__MODULE__{nodes: nodes}, %Node{id: node_id}) do
    nodes
    |> Map.has_key?(node_id)
  end

  def get_nodes(%__MODULE__{nodes: nodes}, node_ids) when is_list(node_ids) do
    Map.take(nodes, node_ids)
    |> Map.values
  end

  def get_nodes(%__MODULE__{nodes: nodes}, %{} = node_ids) do
    Map.take(nodes, node_ids |> Map.keys)
    |> Map.values
  end

  def connect(graph, %Node{id: a} = node_a, %Node{id: b} = node_b, edge_data \\ nil) do
    graph
    |> add_node(node_a)
    |> add_node(node_b)
    |> add_outbound(a, b, edge_data)
    |> add_inbound(b, a, edge_data)
  end

  def connect_bi(graph, %Node{id: a} = node_a, %Node{id: b} = node_b, edge_data \\ nil) do
    graph
    |> connect(node_a, node_b, edge_data)
    |> add_outbound(b, a, edge_data)
    |> add_inbound(a, b, edge_data)
  end

  def are_connected?(%__MODULE__{outbound: outbound}, %Node{id: a}, %Node{id: b}) do
    outbound
    |> Map.get(a, %{})
    |> Map.has_key?(b)
  end

  def outbound(%__MODULE__{nodes: nodes, outbound: outbound}, %Node{id: a}) do
    outbound
    |> Map.get(a, %{})
  end

  def outbound_ids(%__MODULE__{} = graph, %Node{} = node) do
    outbound(graph, node)
    |> Map.keys
  end

  def outbound_nodes(%__MODULE__{} = graph, %Node{} = node) do
    graph
    |> get_nodes(outbound(graph, node))
  end

  def inbound(%__MODULE__{nodes: nodes, inbound: inbound}, %Node{id: a}) do
    inbound
    |> Map.get(a, %{})
  end

  def inbound_ids(%__MODULE__{} = graph, %Node{} = node) do
    inbound(graph, node)
    |> Map.keys
  end

  def inbound_nodes(%__MODULE__{} = graph, %Node{} = node) do
    graph
    |> get_nodes(inbound(graph, node))
  end

  def add_inbound(%__MODULE__{inbound: inbound} = graph, a, b, edge_data \\ nil) do
    a_inbound = Map.get(inbound, a, %{}) |> Map.put(b, edge_data)
    %{graph | inbound: Map.put(inbound, a, a_inbound)}
  end

  def add_outbound(%__MODULE__{outbound: outbound} = graph, a, b, edge_data \\ nil) do
    a_outbound = Map.get(outbound, a, %{}) |> Map.put(b, edge_data)
    %{graph | outbound: Map.put(outbound, a, a_outbound)}
  end
end
