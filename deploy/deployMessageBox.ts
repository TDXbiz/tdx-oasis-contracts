import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    const { getNamedAccounts, upgrades, ethers } = hre;

    const { deployer } = await getNamedAccounts();

    const boxFactory = await ethers.getContractFactory("MessageBox");

    const domain = "oasis.tdx.dev";

    const box = await upgrades.deployProxy(boxFactory, [deployer, domain], {
        initializer: "initialize",
        kind: "uups",
    });

    await box.waitForDeployment();

    console.log("Message Box deployed at: ", box.target);
};

deploy.tags = ["MessageBox"];
export default deploy;
