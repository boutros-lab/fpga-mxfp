Implementing a single head of attention:

- Input tokens x
- Project to Q, K, V
- Dot product yay!
- Apply causal mask
- Softmax
- Apply attention using the value vectors to the input tokens, producing y

Notes:

- Weights & activations are in MXFP

