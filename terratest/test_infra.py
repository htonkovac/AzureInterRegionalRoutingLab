import subprocess, os, sys

def test_login_via_bastion_works():
    private_key = read_tg_output("subscription/us-east-2/vm", "private_key")
    vm_id = read_tg_output("subscription/us-east-2/vm", "vm_id")
    bastion_name = read_tg_output("subscription/us-east-2/bastion", "bastion_name")
    resource_group_name = read_tg_output("subscription/us-east-2/bastion", "resource_group_name")
    
    az ="az network bastion ssh --name "+bastion_name+" --resource-group "+resource_group_name+" --target-resource-id "+vm_id+" --auth-type password --username adminuser"

def read_tg_output(module_path, output_name):
    dir_path = os.path.dirname(os.path.realpath(__file__))
    tg_command = "/usr/local/bin/terragrunt output -raw " + output_name 
    process = subprocess.run(tg_command.split(), cwd=dir_path+"/../terragrunt/"+ module_path, stdout=subprocess.PIPE, text=True)
    #todo error handle
    # return tg_command
    # assert tg_command == "ss"
    assert process.stderr is None
    return process.stdout

def az_command(command):
    dir_path = os.path.dirname(os.path.realpath(__file__))
    return subprocess.run(command.split(), stdout=subprocess.PIPE, text=True)