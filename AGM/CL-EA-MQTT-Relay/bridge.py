import paho.mqtt.client as mqtt
import time, requests, json

class Bridge(object):
    def __on_connect(self, client, userdata, flags, rc):
        #print('on_connect ' + str(rc)) #Debugging
        if rc == self.callback['id']:
            self.callback['pending'] = False
        else:
            self.callback['error'] = rc
            self.callback['source'] = 'on_connect'

    def __on_publish(self, client, userdata, mid):
        # print('on_pub ' + str(mid)) #Debugging
        if mid == self.callback['id']:
            self.callback['pending'] = False
            self.result = 'published'
        else:
            self.callback['error'] = mid
            self.callback['source'] = 'on_publish'

    def __on_subscribe(self, client, userdata, mid, granted_qos):
        # print('on_sub ' + str(mid)) #Debugging
        if mid == self.callback['id']:
            self.callback['pending'] = False
            self.result = 'subscribed'
        else:
            self.callback['error'] = mid
            self.callback['source'] = 'on_subscribe'

    def __on_disconnect(self, client, userdata, rc):
        if rc == self.callback['id']:
            self.callback['pending'] = False
        else:
            self.callback['error'] = rc
            self.callback['source'] = 'on_disconnect'

    def __on_message(self, client, userdata, message): 
        for topic in self.messages:
            if 'topic' in topic and topic['topic'] == message.topic:
                received = str(message.payload, 'UTF-8')
                try:
                    received = int(received)
                except ValueError:
                    try:
                        received = float(received)
                    except ValueError:
                        pass
                topic['payload'] = received

                    #Debugging
                # print ('on_message, topic: ')
                # print(topic['topic'])
                # print ('on_message, payload: ')
                # print (topic['payload'])
                
                break

    def __init__(
        self,
        host,
        port,
        user = None,
        key = None,
    ):
        self.messages = []
        self.result = 'failed'
        self.allowed_callback_attempts = 5
        self.allowed_callback_timeout = 5
        self.hostname = host
        
        self.scoring_element_data = [{
            'topic': '/score_element_1/score',
            'qos': 0
        }]

        self.client = mqtt.Client()

        if user and key:
            self.client.tls_set(tls_version=mqtt.ssl.PROTOCOL_TLS)
            self.client.username_pw_set(user, key)
        
        self.client.on_connect = self.__on_connect
        self.client.on_message = self.__on_message
        self.client.on_publish = self.__on_publish
        self.client.on_subscribe = self.__on_subscribe
        self.client.on_disconnect = self.__on_disconnect

        self.__await_broker_callback(
            self.client.connect,
            host, 
            port
        )
        self.client.loop_start()
        self.disconnected = False
    
    def __disconnect(self):
        self.__await_broker_callback(self.client.disconnect)
        self.client.loop_stop()
        self.messages = []
        self.disconnected = True

    def __reconnect(self):
        self.__await_broker_callback(self.client.reconnect)
        self.client.loop_start()
        self.disconnected = False

    def __await_broker_callback(self, action, *params):
        curr_attempts = 1
        while(curr_attempts <= self.allowed_callback_attempts):
            id = action(*params)
            if type(id) is not int:
                id = id[1] 
            if self.client._thread is None:
                self.client.loop_start() #loop needs to be running for callbacks to respond
            self.callback = {
                'pending': True,
                'id': id,
                'error': None,
                'source': None
            }
            retry = False
            wait_start = time.time()
            while(self.callback['pending']):
                if time.time() - wait_start >= self.allowed_callback_timeout:
                    #TODO: Add timeout message logging
                    print('callback timeout on host: ' + self.hostname)
                    retry = True
                    break
                if self.callback['error'] is not None:
                    #TODO: Error handling on failing broker responses
                    print('callback type: ' + self.callback['source'] + ' error: ' + str(self.callback['error']) + ' @host: ' + self.hostname)
                    break
            if not retry:
                break
            curr_attempts = curr_attempts + 1
        self.callback = {
            'pending': True,
            'id': None,
            'error': None,
            'source': None
        }

    def __get_data_on(self, topic):
        for message in self.messages:
            if topic == message['topic']:
                return message['payload']
        return None
    
    def subscribe(self, data):
        if self.disconnected:
            self.__reconnect()
        self.messages.append({
            'topic': data['topic'],
            'payload': None
        })
        self.__await_broker_callback(
            self.client.publish,
            data['topic'],
            0,
            0,
            0
        )
        self.__await_broker_callback(
            self.client.subscribe,
            data['topic'],
            data['qos']
        )
        self.__await_broker_callback(
            self.client.publish,
            data['topic'],
            0,
            0,
            0
        )

    def publish(self, data):
        if self.disconnected:
            self.__reconnect()
        self.messages.append({
            'topic': data['topic'],
            'payload': data['payload']
        })
        if data['retain'] == 1:
            retain = True
        else:
            retain = False
        self.__await_broker_callback(
            self.client.publish,
            data['topic'],
            data['payload'],
            data['qos'],
            retain
        )
    
    def ipfs(self, data):
        subtask = data['topic']
        cid = data['payload']
        url = 'https://ipfs.io/ipfs/' + cid
        site = requests.get(url)
            #find the file
        fileIdentifier = 'filename='
        fileType = '.json'
        filenameStart = site.text.find(fileIdentifier)
        filenameEnd = site.text.find(fileType, filenameStart)
        filename = site.text[(filenameStart + len(fileIdentifier)):(filenameEnd + len(fileType))]
        file = requests.get(url + '/' + filename).json()
        if subtask == 'script':
            self.result = self.__script(file)
        else:
            self.result = False
        self.messages = [{ #assuming only one script is executed at a time... for now
            'topic': subtask,
            'payload': cid}]

    def __script(self, script):
        game_start = time.time()
            #TODO: Make game_length a parameter fed to the external adapter?
        game_length = 20 # scripts execute for 1 minutes
        reset_data = {
                'topic': '/daderpyderby/score',
                'payload': 0,
                'qos': 0,
                'retain': 1
            }
        self.subscribe(reset_data) #subscribing to score to validate it publishing after game
        self.publish(reset_data) #resetting score for upcoming game
        for device in self.scoring_element_data:
            self.subscribe(device) #subscribe to relevant scoring topics
        while(time.time() - game_start <= game_length):
            for action in script['script']:
                if action['action'] == 'publish':
                    for topic in action['data']:
                        if 'score' not in topic['topic']: #ignore any attempts to publish directly to scoring topics...
                            self.publish(topic)
                if action['action'] == 'subscribe':
                    for topic in action['data']:
                        self.subscribe(topic)
                if action['action'] == 'delay':
                    time.sleep(action['data'])
        self.__collect_publish_scores()
        self.__reset_game()
        self.__clear_element_scores()
        return True #TODO: add error catching

    def __collect_publish_scores(self):
        score = 0
        main_score_topic = '/daderpyderby/score'
        for device in self.scoring_element_data:
            score_piece = self.__get_data_on(device['topic'])
            if type(score_piece) is int:
                score = score + score_piece
            elif type(score_piece) is str:
                score = score + int(score_piece)
        score_data = {
                'topic': main_score_topic,
                'payload': score,
                'qos': 0,
                'retain': 1
            }
        self.publish(score_data)
        blank_data = {
                'topic': main_score_topic,
                'payload': 0,
                'qos': 0,
                'retain': 0
            }
        self.publish(blank_data) #pushing through blank data to force the previous retained publish

    def __reset_game(self): 
        #TODO: use sensors on vehicles and field to place game into reset position
        motors = [
            '/derby_kart/fr',
            '/derby_kart/fl',
            '/derby_kart/bl',
            '/derby_kart/br']
        for motor_topic in motors:
            motor_data = {
                'topic': motor_topic,
                'payload': 0,
                'qos': 0,
                'retain': 1
            }
            self.publish(motor_data)

    def __clear_element_scores(self):
        for device in self.scoring_element_data:
            device_score_data = {
                'topic': device['topic'],
                'payload': '0',
                'qos': device['qos'],
                'retain': 1
            }
            self.publish(device_score_data)