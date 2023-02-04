using System;
using UnityEngine;

public class Cooldown
{
    private float duration, endTime;

    public bool HasEnded => Time.time > endTime;

    public float TimeRemaining => Math.Max(0, endTime - Time.time);

    public void StartCoolDown()
    {
        endTime = Time.time + duration;
    }

    public void StartCoolDown(float duration)
    {
        endTime = Time.time + duration;
        this.duration = duration;
    }

    public void SetDuration(float duration)
    {
        endTime += this.duration - duration;
        this.duration = duration;
    }
}