Implementing a single head of attention:

- Input tokens x
- Project to Q, K, V
!! CONVERT TO MX-FP
- Dot product yay!
- Apply causal mask (fp32)
- Softmax (fp32)
!! CONVERT TO MX-FP
- Apply attention using the value vectors to the input tokens producing y

Notes:

- Weights & activations are in MXFP

