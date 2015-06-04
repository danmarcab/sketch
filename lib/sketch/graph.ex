defmodule Sketch.Graph do
  defstruct nodes: %{}, inbound: %{}, outbound: %{}

  alias Sketch.Node

  def new, do: %__MODULE__{}

  def add_node(%__MODULE__{nodes: nodes} = graph, %Node{id: id} = node) do
    %{graph | nodes: Map.put(nodes, id, node)}
  end

  def has_node?(%__MODULE__{nodes: nodes}, %Node{id: node_id}) do
    nodes
    |> Map.has_key?(node_id)
  end

  def connect(graph, %Node{id: a} = node_a, %Node{id: b} = node_b) do
    graph
    |> add_node(node_a)
    |> add_node(node_b)
    |> add_outbound(a, b)
    |> add_inbound(b, a)
  end

  def connect_bi(graph, %Node{id: a} = node_a, %Node{id: b} = node_b) do
    graph
    |> connect(node_a, node_b)
    |> add_outbound(b, a)
    |> add_inbound(a, b)
  end

  def are_connected?(%__MODULE__{outbound: outbound}, %Node{id: a}, %Node{id: b}) do
    outbound
    |> Map.get(a, HashSet.new)
    |> Set.member?(b)
  end

  def outbound(%__MODULE__{nodes: nodes, outbound: outbound}, %Node{id: a}) do
    node_ids = outbound
    |> Map.get(a, HashSet.new)
    |> Set.to_list

    Map.take(nodes, node_ids)
    |> Map.values
  end

  def inbound(%__MODULE__{nodes: nodes, inbound: inbound}, %Node{id: a}) do
    node_ids = inbound
    |> Map.get(a, HashSet.new)
    |> Set.to_list

    Map.take(nodes, node_ids)
    |> Map.values
  end

  def add_inbound(%__MODULE__{inbound: inbound} = graph, a, b) do
    a_inbound = Map.get(inbound, a, HashSet.new) |> Set.put(b)
    %{graph | inbound: Map.put(inbound, a, a_inbound)}
  end

  def add_outbound(%__MODULE__{outbound: outbound} = graph, a, b) do
    a_outbound = Map.get(outbound, a, HashSet.new) |> Set.put(b)
    %{graph | outbound: Map.put(outbound, a, a_outbound)}
  end
end
