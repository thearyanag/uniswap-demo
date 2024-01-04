// Dijkstra's algorithm is a popular method for finding 
// the shortest path between nodes in a graph, which can be applied
//  to find the most efficient path for a multi-hop swap in a trading network
//  like Uniswap. The algorithm works by systematically selecting the node 
// with the smallest distance (cost) from the start node, updating the distances
//  of its neighbors, and repeating this process until all nodes have been visited.

function findShortestPath(graph, startNode, endNode) {
    // Track the lowest cost to reach each node
    let costs = {};
    // Track paths
    let parents = {};
    let processed = [];

    // Initialize costs and parents
    Object.keys(graph).forEach(node => {
        if (node !== startNode) {
            let value = graph[startNode][node];
            costs[node] = value || Infinity;
            parents[node] = value ? startNode : null;
        }
    });

    // Find the node with the lowest cost
    let node = findLowestCostNode(costs, processed);

    while (node) {
        let cost = costs[node];
        let children = graph[node];
        for (let n in children) {
            let newCost = cost + children[n];
            if (!costs[n] || costs[n] > newCost) {
                costs[n] = newCost;
                parents[n] = node;
            }
        }
        processed.push(node);
        node = findLowestCostNode(costs, processed);
    }

    // Construct path
    let optimalPath = [endNode];
    let parent = parents[endNode];
    while (parent) {
        optimalPath.push(parent);
        parent = parents[parent];
    }
    optimalPath.reverse();

    return optimalPath;
}

function findLowestCostNode(costs, processed) {
    return Object.keys(costs).reduce((lowest, node) => {
        if (lowest === null || costs[node] < costs[lowest]) {
            if (!processed.includes(node)) {
                lowest = node;
            }
        }
        return lowest;
    }, null);
}

// Representing our graph
let graph = {
    'A': { 'B': 1, 'D': 4 },
    'B': { 'C': 2, 'D': 3 },
    'C': { 'D': 1 },
    'D': {}
};

let startNode = 'A';
let endNode = 'D';

console.log("Shortest path:", findShortestPath(graph, startNode, endNode));
