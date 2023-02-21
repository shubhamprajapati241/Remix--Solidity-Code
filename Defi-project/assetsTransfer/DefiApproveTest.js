
const daiTokenAddress = "0xBa8DCeD3512925e52FE67b1b5329187589072A55";
const deFiDappAddress = "0xfd0a5698a9a4AdF3d9AE8310d405DFb931eAF31C";

import { useWeb3Contract } from "react-moralis";
const { runContractFunction } = useWeb3Contract();

let approveOptions = {
    abi: DAI.abi,
    contractAddress: daiTokenAddress,
    functionName: "approve",
    amount: ethers.utils.parseEther(amountToApprove, "ether"),
    spender: deFiDappAddress, // user approving the SC to transfer
}

const tx = await runContractFunction({
  params: approveOptions,
  onError: (error) => console.log(error), // error loging
  onSuccess: () => {
    handleApproveSuccess(approveOptions.params.amount);
  },
});

tx();