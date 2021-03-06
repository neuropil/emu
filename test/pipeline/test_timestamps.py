import luigi
from src.pipeline.timestamps import ChannelTimestamp as Channel

tasks = [Channel(patient_id=1, channel_id=ch+1) for ch in range(10)]

luigi.build(tasks, local_scheduler=True, workers=3)
