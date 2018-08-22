var Token = artifacts.require('./Token.sol');

// Token Test
describe('TestToken :: ', function() {
    var contract, web3, Me, accounts;

    it('Should deploy the contract', function (done) {
        Token.new()
        .then(function(inst){
            contract = inst.contract;
            web3 = inst.constructor.web3;
            accounts = inst.constructor.web3.eth.accounts;
            Me = accounts[0];

            assert.notEqual(contract.address, null, 'Contract not successfully deployed');
            done();
        });
    });

    describe('Allocate Tokens ::',function(){

        it('Should fail to allocate Negative value tokens (Underflow)', function(done){
            var oldAllowance = Number(contract.allowance.call(Me, accounts[1]));

            contract.approve(accounts[1], -1, {from:Me},
                function(err, res){
                   var newAllowance = Number(contract.allowance.call(Me, accounts[1]));
                   assert.equal(err, null, 'Allocated Negative value tokens');
                   assert.equal(newAllowance, -1, 'Allocated '+ newAllowance +' instead of -1');
                   done();
            })
        })

        it('Should restore allocated value to 0', function(done){
            var oldAllowance = Number(contract.allowance.call(Me, accounts[1]));

            contract.approve(accounts[1], 0, {from:Me},
                function(err, res){
                    var newAllowance = Number(contract.allowance.call(Me, accounts[1]));
                    assert.equal(newAllowance > oldAllowance, false, 'Failed to allocate 0');
                    assert.equal(newAllowance, 0, 'Allocated '+ newAllowance +' instead of 0');
                    done();
            })
        });

        it('Should allocate Non-existent tokens', function(done){
            var oldAllowance = Number(contract.allowance.call(accounts[1], accounts[2]));

            contract.approve(accounts[2], 10, {from:accounts[1]},
                function(err, res){
                   var newAllowance = Number(contract.allowance.call(accounts[1], accounts[2]));
                   assert.equal(newAllowance > oldAllowance, true, 'Failed to allocate tokens');
                   assert.equal(newAllowance, 10, 'Allocated '+ newAllowance +' instead of 10');
                   done();
            })
        })

        it('Should overwrite old allocated value to new value', function(done){
            var oldAllowance = Number(contract.allowance.call(accounts[1], accounts[2]));

            contract.approve(accounts[2], 20, {from:accounts[1]},
                function(err, res){
                   var newAllowance = Number(contract.allowance.call(accounts[1], accounts[2]));
                   assert.equal(newAllowance, 20, 'Allocated '+ newAllowance + ' from previous allocation of '+ oldAllowance);
                   done();
            })
        })

        it('Should fail to spend allocated Non-existent tokens', function(done){
            var allowance = Number(contract.allowance.call(accounts[1], accounts[2]));

            contract.transferFrom(accounts[1], accounts[3], allowance, {from:accounts[2]},
                function(err, res){
                    var allowanceAfter = Number(contract.allowance.call(accounts[1], accounts[2]));
                    assert.equal(allowance, allowanceAfter, 'Allowance must not be deducted after fail transfer.');
                    assert.notEqual(err, null, 'Transfer Non-existent coins via Proxy');
                    done();
            })
        })

        it('Should fail to spend Non-allocated tokens', function(done){
            var allowance = Number(contract.allowance.call(Me, accounts[2]));

            contract.transferFrom(Me, accounts[1], 10, {from:accounts[2]},
                function(err, res){
                    var allowanceAfter = Number(contract.allowance.call(Me, accounts[2]));
                    assert.equal(allowance, allowanceAfter, 'Allowance must not be deducted after fail transfer.');
                    assert.notEqual(err, null, 'Transfer Non-allocated tokens');
                    done();
            })
        })
    })

    describe('Transfer Tokens ::',function(){

        it('Should fail to spend Negative token value from one address to another (Underflow)', function(done){
            var oldBalance = Number(contract.balanceOf.call(accounts[3])),
            oldRogueBalance = Number(contract.balanceOf.call(accounts[2]));

            contract.transfer(accounts[3], -1, {from:accounts[2]},
                function(err, res){
                    var newBalance = Number(contract.balanceOf.call(accounts[3]));
                    var rogueBalance = Number(contract.balanceOf.call(accounts[2]));
                    assert.equal(oldRogueBalance, rogueBalance, 'Sending account was reduced by -1');
                    assert.equal(oldBalance, newBalance, 'Receiving account was increased by -1');
                    done();
            })
        })

        it('Should fail to spend Negative token value from one address to a real address (Underflow)',function(done){
            var oldBalance = Number(contract.balanceOf.call(Me)),
            oldRogueBalance = Number(contract.balanceOf.call(accounts[2]));

            contract.transfer(Me, -1, {from:accounts[2]},
                function(err, res){
                    var newBalance = Number(contract.balanceOf.call(Me));
                    var rogueBalance = Number(contract.balanceOf.call(accounts[2]));
                    assert.equal(oldRogueBalance, rogueBalance, 'Sending account was reduced by -1');
                    assert.equal(oldBalance, newBalance, 'Receiving account was increased by -1');
                    done();
            })
        })

        it('Should fail to spend more token value than balance', function(done){
            var oldBalance = Number(contract.balanceOf.call(accounts[3])),
            oldRogueBalance = Number(contract.balanceOf.call(accounts[2]));

            contract.transfer(accounts[2], 1, {from:Me},
                function(err, res){
                    var newBalance = Number(contract.balanceOf.call(accounts[3]));
                    var rogueBalance = Number(contract.balanceOf.call(accounts[2]));
                    assert.equal(oldBalance, newBalance, 'Receiving account was credited 1 token from the cthulhu');
                    done();
            })
        })

        it('Should successfully spend tokens', function(done){
            var oldBalance = Number(contract.balanceOf.call(accounts[2]));

            contract.transfer(accounts[2], 10, {from:Me},
                function(err, res){
                    var newBalance = Number(contract.balanceOf.call(accounts[2]));
                    assert.equal(newBalance > oldBalance, true, 'Address not credited with token');
                    assert.equal(newBalance, oldBalance + 10, 'Spent '+ newBalance + ' instead of 10');
                    done();
            })
        })
    })
});