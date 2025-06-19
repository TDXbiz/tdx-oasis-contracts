import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, deployments } = hre;

    const { deployer } = await getNamedAccounts();

    await deployments.deploy("InvestorProfile", {
        from: deployer,
        log: true,
    });
};

deploy.tags = ["InvestorProfile"];
export default deploy;
