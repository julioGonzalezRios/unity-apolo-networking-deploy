import pytest
import tftest
import re
from pathlib import Path

profile = {
    "profile": "devsecops"
}

files = ["main.tf", "variables.tf", "outputs.tf", "dev-vars.tfvars"]

file_paths = [Path("..") / file for file in files]

normalized_paths = [str(path.resolve()) for path in file_paths]

@pytest.fixture
def output():
    tf = tftest.TerraformTest("unit")
    tf.setup(extra_files=normalized_paths , workspace_name="test")
    tf.apply(tf_vars=profile,tf_var_file="dev-vars.tfvars")
    yield tf.output()
    tf.destroy(tf_vars=profile,tf_var_file="dev-vars.tfvars", **{"auto_approve": True})

def test(output):
    assert output['aws_region'] == "us-east-1"
    assert bool(re.fullmatch(r'^vpc-[a-f0-9]{17}$', output['vpc_id']))
    for subnet_id in output['subnets_id'].values():
        assert bool(re.fullmatch(r'^subnet-[a-f0-9]{17}$', subnet_id))
    for sg_id in output['security_groups_id'].values():
        assert bool(re.fullmatch(r'^sg-[a-f0-9]{17}$', sg_id))
    assert bool(re.fullmatch(r'^tgw-attach-[a-f0-9]{17}$', output['transit_gateway_attachment_id']))
    for rtb_id in output['expected_route_tables_transit_subnets']:
        assert bool(re.fullmatch(r'^rtb-[a-f0-9]{17}$', rtb_id))