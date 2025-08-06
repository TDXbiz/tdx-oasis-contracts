import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, upgrades, ethers } = hre;

    const { deployer } = await getNamedAccounts();

    const profileFactory = await ethers.getContractFactory("InvestorProfile");

    const profile = await upgrades.deployProxy(profileFactory, [deployer], {
        initializer: "initialize",
        kind: "uups",
    });

    await profile.waitForDeployment();

    console.log("Investor Profile deployed at: ", profile.target);
};

deploy.tags = ["InvestorProfile"];
export default deploy;
