import unittest
from sensor_bridge import Bridge, valid_adapter_event

class ProtocolTests(unittest.TestCase):
    def test_reconnection_changes_session_and_resets_sequence(self):
        b=Bridge();b.set_challenge('a'*24);one=b.packet('jump')
        b.set_challenge('b'*24);two=b.packet('jump')
        self.assertNotEqual(one['session_id'],two['session_id'])
        self.assertEqual(two['sequence'],1)
        self.assertEqual(two['event_id'],1)
    def test_invalid_source_data_is_not_forwarded(self):
        for value in [None,{}, {'event':'jump','sent_at_ms':10}, {'event':'jump','sent_at_ms':2000}, {'event':'unknown','sent_at_ms':1000}]:
            self.assertFalse(valid_adapter_event(value,1000))
        self.assertTrue(valid_adapter_event({'event':'jump','sent_at_ms':980},1000))
    def test_packet_identity_and_monotonic_event(self):
        b=Bridge('device-test');b.set_challenge('a'*24)
        first=b.packet('jump');second=b.packet('jump')
        self.assertEqual(first['device_id'],'device-test')
        self.assertGreater(second['sequence'],first['sequence'])
        self.assertGreater(second['event_id'],first['event_id'])

if __name__=='__main__':unittest.main()
