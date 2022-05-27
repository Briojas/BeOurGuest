import pytest
import adapter

job_run_id = 0x6ba00a293d554b76b7f63a7a5e4527b7
    #vehicle scripts
script_cids = [
    'bafybeidqzb7nkhfcvv55ibuudginz3u7d6d7vgoohh45zdgtppdy7njrby'
]

topic = '/daderpyderby/score'
# topic = '/score_element_1/score'
payload_int = 12

def adapter_setup(test_data):
    a = adapter.Adapter(test_data)
    return a.result

#ipfs  data
@pytest.mark.parametrize('vehicle_script_cids', script_cids)
def test_ipfs(vehicle_script_cids):
    test_data = {
        'id': job_run_id, 
        'data': {
            'action': 'ipfs',
            'topic': 'script', 
            'payload': vehicle_script_cids, 
    }}
    result = adapter_setup(test_data)
    print(result) #Debugging
    assert result['statusCode'] == 200
    assert result['jobRunID'] == job_run_id
    for subtask in result['data']:
        # print(subtask)
        assert type(subtask['payload']) is str
        if test_data['data']['topic'] == 'script':
            assert type(result['result']) is bool

    #pub/sub int data
@pytest.mark.parametrize('test_data', [
    # {'id': job_run_id, 'data': {
    #     'action':'publish',
    #     'topic': topic, 
    #     'qos':0,
    #     'payload': payload_int,
    #     'retain': 1
    # }},
    {'id': job_run_id, 'data': {
        'action':'subscribe',
        'topic': topic, 
        'qos':0,
        'payload': payload_int,
        'retain': 0
    }}
])
def test_pub_sub_ints(test_data):
    result = adapter_setup(test_data)
    print(result) #Debugging
    assert result['statusCode'] == 200
    assert result['jobRunID'] == job_run_id
    for topic in result['data']:
        assert type(topic['payload']) is int
    if test_data['data']['action'] == 'publish':
        assert result['result'] == 'published'
    else:
        assert result['result'] == 'subscribed'