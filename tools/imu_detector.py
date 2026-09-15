"""Experimental body-worn IMU detector. Thresholds require recorded hardware validation."""
import math
from collections import deque

class JumpDetector:
    # Physical Wi-Fi replay: 270 dps cancelled many faster hand gestures.
    # 450 recovered nearly the same events as 600 without changing timing gates.
    # Impulse + unweighting are still required; rotation alone is not a jump.
    MAX_GESTURE_ROTATION_DPS = 450.0
    CONNECTION_GAP_SECONDS = 1.2
    def __init__(self):
        self.reset()

    def reset(self):
        self.samples = deque()
        self.ready = False
        self.baseline = 1.0
        self.last_time = None
        self.impulse_at = None
        self.low_at = None
        self.last_jump = -100.0

    def feed(self, acceleration, gyro, now):
        if self.last_time is not None:
            gap = now-self.last_time
            if gap <= 0 or gap > self.CONNECTION_GAP_SECONDS:
                self.reset()
            elif gap > .15:
                # A brief wireless pause cancels an incomplete gesture, not a
                # completed baseline. Calibration itself still needs continuity.
                self.impulse_at = self.low_at = None
                if not self.ready:self.samples.clear()
        self.last_time = now
        magnitude = math.sqrt(sum(x*x for x in acceleration))
        rotation = math.sqrt(sum(x*x for x in gyro))
        if not self.ready:
            # Three continuous seconds of near-gravity, low-rotation samples.
            if not .8 <= magnitude <= 1.2 or rotation > 12:
                self.samples.clear()
                return None
            self.samples.append((now, magnitude))
            while self.samples and now-self.samples[0][0] > 3.1:
                self.samples.popleft()
            if len(self.samples) < 200 or now-self.samples[0][0] < 3:
                return None
            mean = sum(s[1] for s in self.samples)/len(self.samples)
            variance = sum((s[1]-mean)**2 for s in self.samples)/len(self.samples)
            if variance > .0016:
                return None
            self.baseline = mean
            self.ready = True
            return 'ready'
        if now-self.last_jump < .65 or rotation > self.MAX_GESTURE_ROTATION_DPS:
            self.impulse_at = self.low_at = None
            return None
        relative = magnitude/self.baseline
        if self.impulse_at is None:
            if relative > 1.4:
                self.impulse_at = now
            return None
        if now-self.impulse_at > .35:
            self.impulse_at = self.low_at = None
            return None
        if relative < .72:
            if self.low_at is None:
                self.low_at = now
            if now-self.low_at >= .025:
                self.last_jump = now
                self.impulse_at = self.low_at = None
                return 'jump'
        else:
            self.low_at = None
        return None
