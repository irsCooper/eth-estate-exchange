const {ethers} = require('hardhat')

async function deploy() {
    const EstNft = await ethers.getContractFactory("EstNft")
    const estNft = await EstNft.deploy()

    const Eston = await ethers.getContractFactory("Eston")
    const eston = await Eston.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 1000000000)

    const Con = await ethers.getContractFactory("Contract")
    const con = await Con.deploy(estNft.target, eston.target)    

    const fs = require('fs')
    const path = require('path')

    const file = path.join(__dirname, "./artifacts/contracts/Exchange.sol/Contract.json")

    const data = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file)) : {}
    data.address = con.target

    fs.writeFileSync(file, JSON.stringify(data))
}

deploy()