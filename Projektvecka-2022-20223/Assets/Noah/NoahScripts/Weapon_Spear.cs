using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

/// <summary>
/// Hit1 = First animation for light combo
/// Hit2 = Second animation for light combo
/// Hit3 = Third animation for light combo
/// ChargeHit1 = First animation for charged attack (Hold)
/// ChargeHit2 = Second animation for charged attack (Released)
/// </summary>
public class Weapon_Spear : MonoBehaviour
{
    private Animator anim;
    public float cooldownTime = 2f;
    private float nextFireTime = 0f;
    public static int noOfClicks = 0;
    float lastClickedTime = 1;
    float maxComboDelay = 1;

    public float chargeTime;
    public float chargedDamage;
    private bool isCharging = false;

    public float damage = 0;

    private void Awake()
    {
        anim = GetComponent<Animator>();
    }

    void Update()
    {
        bool noahVetInte = anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f;
        // If animation is past 0.7 in normalized time and has a specific name, set the corresponding animator bool parameter to false
        if (noahVetInte && anim.GetCurrentAnimatorStateInfo(0).IsName("Spear_Test1"))
        {
            anim.SetBool("Spear_Test1", false);
            anim.SetBool("ChargeHit1", false);
        }
        if (noahVetInte && anim.GetCurrentAnimatorStateInfo(0).IsName("Hit2"))
        {
            anim.SetBool("Hit2", false);
            anim.SetBool("ChargeHit1", false);
        }

        if (noahVetInte && anim.GetCurrentAnimatorStateInfo(0).IsName("Hit3"))
        {
            anim.SetBool("Hit3", false);
            noOfClicks = 0;
            anim.SetBool("ChargeHit1", false);
        }
        if (noahVetInte && anim.GetCurrentAnimatorStateInfo(0).IsName("ChargeHit1"))
        {
            anim.SetBool("ChargeHit1", false);
        }
        if (noahVetInte && anim.GetCurrentAnimatorStateInfo(0).IsName("ChargeHit2"))
        {
            anim.SetBool("ChargeHit2", false);
            anim.SetBool("ChargeHit1", false);
            noOfClicks = 0;
        }
        if (noahVetInte && anim.GetCurrentAnimatorStateInfo(0).IsName("SpearThrow1"))
        {
            anim.SetBool("SpearThrow1", false);
        }
        if (noahVetInte && anim.GetCurrentAnimatorStateInfo(0).IsName("SpearThrow2"))
        {
            anim.SetBool("SpearThrow2", false);
        }

        // Reset noOfClicks if the maxComboDelay time has passed since the last click
        if (Time.time - lastClickedTime > maxComboDelay)
            noOfClicks = 0;

        if (Keyboard.current.qKey.wasReleasedThisFrame && !isCharging && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f)
        {
            anim.SetBool("SpearThrow2", true);
        }

        if (Mouse.current.rightButton.wasReleasedThisFrame && !isCharging && anim.GetCurrentAnimatorStateInfo(1).normalizedTime > 0.7f)
        {
            anim.SetBool("ChargeHit1", false);
            anim.SetBool("ChargeHit2", true);
        }
    }

    public void ThrowSpear()
    {
        if (Time.time <= nextFireTime) return;

        anim.SetBool("SpearThrow1", true);
        anim.SetBool("SpearThrow2", false);
        
        print("is woking!");
        SpearThrow spearThrow = GetComponent<SpearThrow>();
        spearThrow.Release();
    }

    public void RightClick()
    {
        if (Time.time <= nextFireTime) return;

        anim.SetBool("ChargeHit2", false);
        anim.SetBool("ChargeHit1", true);
        StartCoroutine(ChargedAttack());
    }

    public void LeftClick()
    {
        if (Time.time <= nextFireTime) return; //cooldown time

        // Update the time of the last click
        lastClickedTime = Time.time;
        noOfClicks++;
        // If noOfClicks is 1, set the Spear_Test1 animator bool parameter to true
        if (noOfClicks == 1)
        {
            anim.SetBool("Spear_Test1", true);
        }
        // Clamp noOfClicks between 0 and 3
        noOfClicks = Mathf.Clamp(noOfClicks, 0, 3);

        // If noOfClicks is >= 2 and the Spear_Test1 animation has finished, set the Hit2 animator bool parameter to true
        if (noOfClicks >= 2 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Spear_Test1"))
        {
            anim.SetBool("Spear_Test1", false);
            anim.SetBool("Hit2", true);
        }
        // If noOfClicks is >= 2 and the Hit2 animation has finished, set the Hit3 animator bool parameter to true
        if (noOfClicks >= 3 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Hit2"))
        {
            anim.SetBool("Hit2", false);
            anim.SetBool("Hit3", true);
        }
    }

    private IEnumerator ChargedAttack()
    {
        float startTime = Time.time;
        float endTime = 0f;

        isCharging = true;
        while (Mouse.current.rightButton.IsActuated())
        {
            endTime = Time.time;
            yield return null;
        }
        chargeTime = endTime - startTime;
        chargedDamage = damage * chargeTime;
        isCharging = false;
        anim.SetBool("ChargeHit2", true);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("RatTeam"))
        {
            Health health = other.GetComponent<Health>();

            if (anim.GetCurrentAnimatorStateInfo(0).IsName("ChargeHit2"))
            {
                health.TakingDamage(chargedDamage);
            }
            else if (anim.GetCurrentAnimatorStateInfo(0).IsName("Spear_Test1") ||
                     anim.GetCurrentAnimatorStateInfo(0).IsName("Hit2") ||
                     anim.GetCurrentAnimatorStateInfo(0).IsName("Hit3"))
            {
                health.TakingDamage(damage);
            }
        }
    }
}