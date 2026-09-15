import json
import math
import unittest
from esp32_receiver import Receiver, SampleGate
from imu_detector import JumpDetector

TOKEN='a'*32

def sample(seq,ms,acc=1.0,gyro=0.0,**changes):
    p=dict(v=1,token=TOKEN,device='esp32-test',boot='boot1',seq=seq,ms=ms,a=[0,0,acc],g=[0,0,gyro])
    p.update(changes)
    return json.dumps(p).encode()

class DetectorTests(unittest.TestCase):
    def test_fast_gesture_with_420_dps_rotation_is_detected(self):
        d=JumpDetector();self.stable(d)
        wave=[1.65]*6+[.5]*10+[1.9]*6+[1.0]*63
        events=[d.feed([0,0,a],[0,0,420],3.3+n*.01) for n,a in enumerate(wave)]
        self.assertEqual(events.count('jump'),1)
    def test_fast_rotation_without_impulse_and_unweighting_is_not_jump(self):
        d=JumpDetector();self.stable(d)
        for n in range(400):
            self.assertIsNone(d.feed([0,0,1],[0,0,420],3.3+n*.01))
    def test_fast_gesture_has_same_result_on_each_axis_and_sign(self):
        for axis in range(3):
            for sign in [-1,1]:
                d=JumpDetector()
                for n in range(330):
                    a=[0,0,0];a[axis]=sign;d.feed(a,[0,0,0],n*.01)
                events=[]
                for n,magnitude in enumerate([1.65]*6+[.5]*10+[1.9]*6+[1]*63):
                    a=[0,0,0];a[axis]=sign*magnitude
                    g=[0,0,0];g[axis]=sign*420
                    events.append(d.feed(a,g,3.3+n*.01))
                self.assertEqual(events.count('jump'),1,(axis,sign))
    def test_repeated_gestures_with_measured_hand_rotation(self):
        d=JumpDetector();self.stable(d);events=[]
        wave=([1.65]*6+[.5]*10+[1.9]*6+[1.0]*63)*4
        for n,a in enumerate(wave):
            events.append(d.feed([0,0,a],[0,0,240],3.3+n*.01))
        self.assertEqual(events.count('jump'),4)
    def test_rotation_without_jump_acceleration_does_not_fire(self):
        d=JumpDetector();self.stable(d)
        for n in range(400):
            self.assertIsNone(d.feed([0,0,1],[0,0,240],3.3+n*.01))
    def stable(self,d,seconds=3.3,start=0):
        result=[]
        for n in range(int(seconds*100)):
            result.append(d.feed([0,0,1],[0,0,0],start+n*.01))
        return result
    def test_stillness_calibrates_once(self):
        d=JumpDetector();self.assertEqual(self.stable(d).count('ready'),1)
    def test_movement_prevents_calibration(self):
        d=JumpDetector()
        for n in range(500):d.feed([0,0,1.3],[0,0,0],n*.01)
        self.assertFalse(d.ready)
    def test_rotation_prevents_calibration(self):
        d=JumpDetector()
        for n in range(500):d.feed([0,0,1],[0,0,30],n*.01)
        self.assertFalse(d.ready)
    def test_impulse_then_unweighting_emits_only_one_jump(self):
        d=JumpDetector();self.stable(d);events=[]
        wave=[1.65]*6+[.5]*10+[1.9]*6+[1.0]*30
        for n,a in enumerate(wave):events.append(d.feed([0,0,a],[0,0,0],3.3+n*.01))
        self.assertEqual(events.count('jump'),1)
    def test_isolated_impact_or_freefall_is_not_jump(self):
        for wave in [[1.9]*3+[1]*60,[.2]*10+[1]*60]:
            d=JumpDetector();self.stable(d)
            self.assertNotIn('jump',[d.feed([0,0,a],[0,0,0],3.3+n*.01) for n,a in enumerate(wave)])
    def test_normal_small_motion_no_jumps(self):
        d=JumpDetector();self.stable(d)
        for n in range(400):self.assertIsNone(d.feed([0,0,1+.2*math.sin(n*.3)],[0,0,10],3.3+n*.01))
    def test_gap_invalidates_calibration(self):
        d=JumpDetector();self.stable(d);d.feed([0,0,1],[0,0,0],5)
        self.assertFalse(d.ready)

class TransportTests(unittest.TestCase):
    def test_brief_wifi_gap_preserves_calibration_and_next_jump(self):
        sent=[];r=Receiver(TOKEN,sent.append);r.challenge('b'*24)
        for n in range(340):r.sample(sample(n+1,n*10),'ip',n*.01)
        r.tick(4.1)
        self.assertTrue(r.detector.ready)
        wave=[1.0]*2+[1.65]*6+[.5]*10+[1.9]*6
        for n,a in enumerate(wave):
            r.sample(sample(420+n,4200+n*10,acc=a),'ip',4.2+n*.01)
        self.assertEqual(sum(p['event']=='jump' for p in sent),1)
        self.assertEqual(sum(p['event']=='calibration_start' for p in sent),1)
    def test_wifi_burst_uses_measurement_time_for_jump(self):
        sent=[];r=Receiver(TOKEN,sent.append);r.challenge('b'*24)
        for n in range(340):r.sample(sample(n+1,n*10),'ip',n*.01)
        wave=[1.65]*6+[.5]*10
        for n,a in enumerate(wave):
            # Fresh packets arrive in groups; acquisition remains at 100 Hz.
            arrival=3.45+n*.00001 if n<6 else 3.55+(n-6)*.00001
            r.sample(sample(341+n,3400+n*10,acc=a),'ip',arrival)
        self.assertEqual(sum(p['event']=='jump' for p in sent),1)
    def test_eight_consecutive_movements_keep_emitting_unique_jumps(self):
        sent=[];r=Receiver(TOKEN,sent.append);r.challenge('b'*24)
        wave=[1.0]*340+([1.65]*6+[.5]*10+[1.9]*6+[1.0]*63)*8
        for n,a in enumerate(wave):r.sample(sample(n+1,n*10,acc=a),'ip',n*.01)
        jumps=[p['event_id'] for p in sent if p['event']=='jump']
        self.assertEqual(jumps,list(range(1,9)))
        self.assertTrue(r.detector.ready)
    def test_ready_retries_recover_early_or_lost_confirmation_only_with_live_data(self):
        sent=[];r=Receiver(TOKEN,sent.append);r.challenge('b'*24)
        for n in range(420):r.sample(sample(n+1,n*10),'ip',n*.01)
        ready=[p for p in sent if p['event']=='ready']
        self.assertGreaterEqual(len(ready),3)
        self.assertTrue(all(p['stable'] for p in ready))
        self.assertEqual(len({p['sequence'] for p in ready}),len(ready))
        count=len(sent);r.tick(5.5)
        self.assertEqual(len(sent),count)
        self.assertFalse(r.detector.ready)
        r.sample(sample(421,4200),'ip',5.51)
        self.assertEqual(len(sent),count)  # Delayed input cannot revive ready.
    def test_invalid_token_vector_and_nonfinite_rejected(self):
        for body in [sample(1,10,token='x'*32),sample(1,10,a=[1]),sample(1,10,acc=float('nan')),sample(True,10),b'[]',b'x'*600]:
            self.assertIsNone(SampleGate(TOKEN).accept(body,'ip',1))
    def test_duplicate_out_of_order_and_other_device_rejected(self):
        g=SampleGate(TOKEN);self.assertIsNotNone(g.accept(sample(2,20),'ip',1))
        for body,ip in [(sample(2,20),'ip'),(sample(1,10),'ip'),(sample(3,30),'other-ip'),(sample(3,30,boot='boot2'),'ip')]:
            self.assertIsNone(g.accept(body,ip,1.01))
    def test_delayed_packet_rejected(self):
        g=SampleGate(TOKEN);g.accept(sample(1,10),'ip',1)
        self.assertIsNone(g.accept(sample(2,20),'ip',1.5))
    def test_game_challenge_recalibrates_and_disconnection_has_no_heartbeat(self):
        sent=[];r=Receiver(TOKEN,sent.append);r.challenge('b'*24)
        for n in range(340):r.sample(sample(n+1,n*10),'ip',n*.01)
        self.assertTrue(r.detector.ready)
        self.assertEqual([p['event'] for p in sent].count('ready'),1)
        r.challenge('c'*24);self.assertFalse(r.detector.ready)
        count=len(sent);r.tick(4)
        self.assertEqual(len(sent),count)
        r.tick(6);self.assertIsNone(r.gate.identity)
    def test_jump_reaches_existing_game_packet_format(self):
        sent=[];r=Receiver(TOKEN,sent.append);r.challenge('b'*24)
        for n in range(330):r.sample(sample(n+1,n*10),'ip',n*.01)
        for n,a in enumerate([1.65]*6+[.5]*10+[1]*40,330):r.sample(sample(n+1,n*10,acc=a),'ip',n*.01)
        jumps=[p for p in sent if p['event']=='jump']
        self.assertEqual(len(jumps),1)
        self.assertEqual(jumps[0]['protocol_version'],1)
        self.assertEqual(jumps[0]['challenge'],'b'*24)
        self.assertEqual(jumps[0]['device_id'],'esp32-test')
    def test_reconnect_with_boot_change_needs_new_calibration(self):
        sent=[];r=Receiver(TOKEN,sent.append);r.challenge('b'*24)
        for n in range(330):r.sample(sample(n+1,n*10),'ip',n*.01)
        r.tick(6)
        r.sample(sample(1,0,boot='boot2'),'ip',6.01)
        self.assertFalse(r.detector.ready)
        self.assertEqual(sent[-2]['event'],'calibration_start')

if __name__=='__main__':unittest.main()
