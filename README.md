1. There is a variable called rate that can be used to change the conversion rate. During the different sale periods.

2. Send money from coinbase or any other exchange wallet and later claim the tokens.

3. Give bonus to advisiors.
               
Todo:
1. When a user upload their prescriptions then give them some HLT.

QUESTIONS:
1. What if there is no more tokens available on Foundation address and price is not zero?
Currently, we will try to send tham anyway, will fail on SafeMath.sub() and transaction will be reverted eating all gas.
We can check if there are tokens available before sending internal transaction, but this will eat some gas for each token sale and for now (before Metropolis release) require() will eat all gas anyway.