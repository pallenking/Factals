//
//  HiddenState.swift
//  Factals
//
//  Created by Allen King on 4/2/23.
//

import Foundation

enum Contents {
	case leaf(value: Int)
	case subnodes(nodes: [Contents])
//	var localHidenState : [Int] = []
}

let tree0 = Contents.leaf(value: 0)
let tree1 = Contents.leaf(value: 1)
let tree2 = Contents.subnodes(nodes: [tree1, tree1])

class FactalBit {
	var scalarValue : Int = 0
	init(scalarValue: Int) {
		self.scalarValue = scalarValue
	}
}
/*
tell me about an RNN whose hidden state is a tree of bidirectional compositional functions.
It is possible to design a Recurrent Neural Network (RNN) where the hidden state is a tree of bidirectional compositional functions. Such an architecture is called a Tree-LSTM, and it has been used in various natural language processing (NLP) tasks.

In a Tree-LSTM, each node in the tree has an associated hidden state vector, which is computed based on the hidden states of its child nodes. The computation at each node involves bidirectional compositional functions, which allow the model to capture both forward and backward dependencies between words in a sentence.

The compositional function used in Tree-LSTM is similar to the one used in standard LSTM networks, but instead of operating on a single vector, it operates on two vectors corresponding to the child nodes. The resulting vector is then combined with the vector corresponding to the current node, to produce the final hidden state vector.

Tree-LSTM networks have been successfully applied to various NLP tasks, including sentiment analysis, question answering, and language modeling. One of the main advantages of Tree-LSTM is that it can capture the hierarchical structure of natural language, which is essential for many NLP tasks.

However, building and training a Tree-LSTM can be computationally expensive due to the large number of parameters involved. Additionally, designing an effective architecture for a particular task can be challenging, and requires a good understanding of both the task and the data.
 */
