import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CrowdFunding = buildModule("CrowdFunding", (m) => {
  const crowdFunding = m.contract("CrowdFunding");

  return { crowdFunding };
});

export default CrowdFunding;
