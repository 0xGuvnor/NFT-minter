
module.exports = async ({deployments, getNamedAccounts}) => {
    const {deploy, log} = deployments;
    const {deployer} = await getNamedAccounts();
}

module.exports.tags =['all']